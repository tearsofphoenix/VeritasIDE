#include "selection.h"


	static NSUInteger count_columns (NSString * buffer, index_t caret)
	{
		NSUInteger const tabSize = buffer.indent().tab_size();
		NSString * str = buffer.substr(buffer.begin(buffer.convert(caret.index).line), caret.index);
		NSUInteger len = 0;
		citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
			len += *ch == '\t' ? tabSize - (len % tabSize) : (text::OakTextIsEastAsianWidth(*ch) ? 2 : 1);
		return len + caret.carry;
	}

	static index_t at_column (NSString * buffer, NSUInteger line, NSUInteger column)
	{
		NSUInteger const tabSize = buffer.indent().tab_size();
		NSUInteger caret = buffer.begin(line), len = 0;
		NSString * str = buffer.substr(caret, buffer.eol(line));
		citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
		{
			if(len == column)
				return caret + (&ch - str.data());

			NSUInteger chWidth = *ch == '\t' ? tabSize - (len % tabSize) : (text::OakTextIsEastAsianWidth(*ch) ? 2 : 1);
			if(len + chWidth > column || *ch == '\n')
				return index_t(caret + (&ch - str.data()), column - len);

			len += chWidth;
		}
		return index_t(caret + str.size(), column - len);
	}

	NSString * kCharacterClassWord    = @"word";
	NSString * kCharacterClassSpace   = @"space";
	NSString * kCharacterClassOther   = @"other";
	NSString * kCharacterClassUnknown = @"unknown";

	NSString * character_class (NSString * buffer, NSUInteger index)
	{
		OakBundleItem * match;
		id value = bundles::value_for_setting("characterClass", buffer.scope(index), &match);
		if(match)
			return boost::get<NSString *>(value);
		else if(text::is_word_char(buffer[index]))
			return kCharacterClassWord;
		else if(text::is_whitespace(buffer[index]))
			return kCharacterClassSpace;
		return kCharacterClassOther;
	}

	static BOOL is_part_of_word (NSString * buffer, NSUInteger index)
	{
		return character_class(buffer, index) != kCharacterClassSpace && character_class(buffer, index) != kCharacterClassOther;
	}

	static NSUInteger extend_scope_left (NSString * buffer, NSUInteger caret, scope::scope_t  scope)
	{
		while(caret && buffer.scope(caret).left.has_prefix(scope))
			caret -= buffer[caret-1].size();
		return caret;
	}

	static NSUInteger extend_scope_right (NSString * buffer, NSUInteger caret, scope::scope_t  scope)
	{
		while(caret < buffer.size() && buffer.scope(caret).right.has_prefix(scope))
			caret += buffer[caret].size();
		return caret;
	}

	static ranges_t sanitize (NSString * buffer, ranges_t  selection)
	{
		// TODO Ensure ranges do not overlap.

		std::set<ng::range_t> set;
		ranges_t res;
		iterate(range, selection)
		{
			range_t r(index_t(buffer.sanitize_index(range->first.index), range->first.carry), index_t(buffer.sanitize_index(range->last.index), range->last.carry), range->columnar, range->freehanded, range->unanchored);
			if(set.find(r) == set.end())
			{
				res.push_back(r);
				set.insert(r);
			}
		}
		return res;
	}

	static index_t cap (NSString * buf, text::pos_t  pos)
	{
		NSUInteger line = OakCap<NSUInteger>(0, pos.line,   buf.lines()-1);
		NSUInteger col  = OakCap<NSUInteger>(0, pos.column, buf.eol(line) - buf.begin(line));
		index_t res = buf.sanitize_index(buf.convert(text::pos_t(line, col)));
		if(pos.offset && res.index < buf.size() && buf[res.index] == "\n")
			res.carry = pos.offset;
		return res;
	}

	static range_t cap (NSString * buf, OakTextRange * range)
	{
		return range_t(cap(buf, range.from), cap(buf, range.to), range.columnar, false, true);
	}

	ranges_t convert (NSString * buf, text::selection_t  sel)
	{
		ranges_t res;
		iterate(range, sel)
			res.push_back(cap(buf, *range));
		return sanitize(buf, res);
	}

	// =======================
	// = Typing Pair Support =
	// =======================

	static std::vector< std::pair<NSString *, NSString *> > character_pairs (OakScopeContext *  scope, NSString * key)
	{
		std::vector< std::pair<NSString *, NSString *> > res;

		id value = bundles::value_for_setting(key, scope);
		if(plist::array_t const* array = boost::get<plist::array_t>(&value))
		{
			iterate(pair, *array)
			{
				if(plist::array_t const* value = boost::get<plist::array_t>(&*pair))
				{
					NSString * a1 = value->size() == 2 ? boost::get<NSString *>(&(*value)[0]) : NULL;
					NSString * a2 = value->size() == 2 ? boost::get<NSString *>(&(*value)[1]) : NULL;
					if(a1 && a2 && *a1 != *a2)
						res.push_back(std::make_pair(*a1, *a2));
				}
			}
		}
		else
		{
			res.push_back(std::make_pair("(", ")"));
			res.push_back(std::make_pair("{", "}"));
			res.push_back(std::make_pair("[", "]"));
		}

		return res;
	}

	namespace
	{
		struct character_pair_t
		{
			character_pair_t () { }
			character_pair_t (NSString * first, NSString * second, BOOL matchedFirst) : first(first), second(second), matched_first(matchedFirst), initialized(true) { }
			explicit operator BOOL () const { return initialized; }

			NSString * first, second;
			BOOL matched_first, initialized = false;
		};
	}

	static BOOL does_match (NSString * buffer, NSUInteger index, NSString * ch)
	{
		return index + ch.size() <= buffer.size() && ch == buffer.substr(index, index + ch.size());
	}

	static character_pair_t first_match (NSString * buffer, NSUInteger index, std::vector< std::pair<NSString *, NSString *> >  pairs)
	{
		citerate(pair, pairs)
		{
			if(does_match(buffer, index, pair->first))
				return character_pair_t(pair->first, pair->second, true);
			else if(does_match(buffer, index, pair->second))
				return character_pair_t(pair->first, pair->second, false);
		}
		return character_pair_t();
	}

	static NSUInteger begin_of_typing_pair (NSString * buffer, NSUInteger caret, BOOL moveToBefore)
	{
		NSUInteger orgCaret = caret;
		auto pairs = character_pairs(buffer.scope(caret), "highlightPairs");
		BOOL skip = false;
		while(0 < caret)
		{
			caret -= buffer[caret-1].size();
			auto pair = first_match(buffer, caret, pairs);
			if(!pair)
				continue;

			if(pair.matched_first)
			{
				if(caret + pair.first.size() != orgCaret || moveToBefore)
					return caret + (skip || moveToBefore || orgCaret < caret + pair.first.size() ? 0 : pair.first.size());
				continue;
			}

			if(!moveToBefore && orgCaret <= caret + pair.second.size())
			{
				skip = true;
				continue;
			}

			NSString * openCh  = pair.first;
			NSString * closeCh = pair.second;

			for(NSUInteger balance = 1; balance != 0 && 0 < caret; )
			{
				caret -= buffer[caret-1].size();
				if(does_match(buffer, caret, openCh))
					--balance;
				else if(does_match(buffer, caret, closeCh))
					++balance;
			}
		}
		return orgCaret;
	}

	static NSUInteger end_of_typing_pair (NSString * buffer, NSUInteger caret, BOOL moveToAfter)
	{
		NSUInteger orgCaret = caret;
		auto pairs = character_pairs(buffer.scope(caret), "highlightPairs");
		BOOL skipEnd = false;
		if(!moveToAfter)
		{
			if(auto pair = first_match(buffer, caret, pairs))
			{
				skipEnd = pair.matched_first;
				caret += pair.matched_first ? pair.first.size() : pair.second.size();
			}
		}

		while(caret < buffer.size())
		{
			auto pair = first_match(buffer, caret, pairs);
			if(!pair)
			{
				caret += buffer[caret].size();
				continue;
			}

			if(!pair.matched_first)
				return caret + (skipEnd || moveToAfter ? pair.second.size() : 0);

			NSString * openCh  = pair.first;
			NSString * closeCh = pair.second;

			caret += openCh.size();
			for(NSUInteger balance = 1; balance != 0 && caret < buffer.size(); )
			{
				if(does_match(buffer, caret, closeCh))
				{
					--balance;
					caret += closeCh.size();
				}
				else if(does_match(buffer, caret, openCh))
				{
					++balance;
					caret += openCh.size();
				}
				else
				{
					caret += buffer[caret].size();
				}
			}
		}

		return orgCaret;
	}

	// ====================
	// = Columnar Support =
	// ====================

	BOOL not_empty (NSString * buffer, ranges_t  selection)
	{
		BOOL isEmpty = true;
		iterate(range, selection)
			isEmpty = isEmpty && (range->empty() || (range->columnar && count_columns(buffer, range->first) == count_columns(buffer, range->last)));
		return !isEmpty;
	}

	BOOL multiline (NSString * buffer, ranges_t  selection)
	{
		BOOL isMultiline = false;
		iterate(range, selection)
			isMultiline = isMultiline || buffer.convert(range->first.index).line != buffer.convert(range->last.index).line;
		return isMultiline;
	}

	ranges_t dissect_columnar (NSString * buffer, ranges_t  selection)
	{
		ranges_t res;
		iterate(range, selection)
		{
			if(range->columnar && !range->empty())
			{
				NSUInteger colA = count_columns(buffer, range->first);
				NSUInteger colB = count_columns(buffer, range->last);

				NSUInteger lineA = buffer.convert(range->first.index).line;
				NSUInteger lineB = buffer.convert(range->last.index).line;

				NSUInteger fromLine = MIN(lineA, lineB), fromCol = MIN(colA, colB);
				NSUInteger toLine   = MAX(lineA, lineB), toCol   = MAX(colA, colB);

				for(NSUInteger n = fromLine; n <= toLine; ++n)
				{
					index_t from = at_column(buffer, n, fromCol), to = at_column(buffer, n, toCol);
					res.push_back(range_t(from, to, false, from.carry || to.carry));
				}
			}
			else
			{
				res.push_back(range_t(range->min(), range->max(), range->columnar, range->freehanded));
			}
		}
		return res;
	}

	ranges_t toggle_columnar (ranges_t  selection)
	{
		ranges_t res = selection;
		if(res.size() != 0)
		{
			range_t& last = res.last();
			last = range_t(last.first, last.last, !last.empty() && !last.columnar, last.freehanded);
		}
		return res;
	}

	// =================
	// = Move Caret(s) =
	// =================

	static BOOL all_spaces (NSString * buffer, NSUInteger from, NSUInteger to)
	{
		BOOL allSpaces = true;
		while(from < to && allSpaces)
			allSpaces = allSpaces && buffer[from++] == " ";
		return allSpaces;
	}

	static BOOL all_whitespace (NSString * buffer, NSUInteger from, NSUInteger to)
	{
		BOOL res = true;
		static NSString * whitespaceChars[] = { " ", "\t", "\n" };
		while(from < to && res)
			res = res && oak::contains(std::begin(whitespaceChars), std::end(whitespaceChars), buffer[from++]);
		return res;
	}

	static NSUInteger end_of_leading_indent (NSString * buffer, NSUInteger line)
	{
		NSUInteger bol = buffer.begin(line);
		NSUInteger eol = buffer.eol(line);
		while(bol < eol && isspace(OakUTF8StringToChar(buffer[bol])))
			++bol;
		return bol;
	}

	static index_t move (NSString * buffer, index_t  index, move_unit_type unit, id<OakLayoutMovement> layout)
	{
		NSUInteger const caret = index.index;
		NSUInteger const line  = buffer.convert(caret).line;

		if((unit == kSelectionMoveLeft || unit == kSelectionMoveRight) && buffer.indent().soft_tabs())
		{
			NSUInteger const bol = buffer.begin(line);
			if((caret - bol) % buffer.indent().indent_size() == 0)
			{
				if(all_spaces(buffer, bol, caret))
				{
					NSUInteger const tabSize = buffer.indent().tab_size();
					if(unit == kSelectionMoveLeft && caret != bol)
						return caret - tabSize;
					else if(unit == kSelectionMoveRight && caret + tabSize <= buffer.eol(line) && all_spaces(buffer, caret, caret + tabSize))
						return caret + tabSize;
				}
			}
		}

		switch(unit)
		{
			case kSelectionMoveToBeginOfDocument:     return 0; 
			case kSelectionMoveToEndOfDocument:       return buffer.size();
			case kSelectionMoveToBeginOfParagraph:    return buffer.begin(line);
			case kSelectionMoveToEndOfParagraph:      return buffer.eol(line);
			case kSelectionMoveToBeginOfLine:         return buffer.begin(line);
			case kSelectionMoveToEndOfLine:           return buffer.eol(line);
			case kSelectionMoveToBeginOfSoftLine:     return layout ? layout->index_at_bol_for(caret) : buffer.begin(line);
			case kSelectionMoveToEndOfSoftLine:       return layout ? layout->index_at_eol_for(caret) : buffer.eol(line);
			case kSelectionMoveUp:                    return layout ? layout->index_above(index) : (line ? at_column(buffer, line-1, count_columns(buffer, index)) : 0);
			case kSelectionMoveDown:                  return layout ? layout->index_below(index) : (line+1 < buffer.lines() ? at_column(buffer, line+1, count_columns(buffer, index)) : buffer.size());
			case kSelectionMoveLeft:                  return layout ? layout->index_left_of(caret)  : (caret ? caret - buffer[caret-1].size() : caret);
			case kSelectionMoveRight:                 return layout ? layout->index_right_of(caret) : (caret < buffer.size() ? caret + buffer[caret].size() : caret);
			case kSelectionMoveToBeginOfTypingPair:   return begin_of_typing_pair(buffer, caret, false);
			case kSelectionMoveToEndOfTypingPair:     return end_of_typing_pair(buffer, caret, false);
			case kSelectionMovePageUp:                return layout ? layout->page_up_for(index)   : index;
			case kSelectionMovePageDown:              return layout ? layout->page_down_for(index) : index;

			case kSelectionMoveToBeginOfIndentedLine:
			{
				NSUInteger bol = buffer.begin(line);
				NSUInteger eoi = end_of_leading_indent(buffer, line);
				return eoi < caret ? eoi : bol;
			}
			break;

			case kSelectionMoveToEndOfIndentedLine:
			{
				NSUInteger eoi = end_of_leading_indent(buffer, line);
				NSUInteger eol = buffer.eol(line);
				return caret < eoi ? eoi : eol;
			}
			break;

			case kSelectionMoveToBeginOfHardParagraph:
			{
				if(line == 0)
					return 0;

				for(NSUInteger n = line-1; n > 0; --n)
				{
					NSString * line = buffer.substr(buffer.begin(n), buffer.end(n));
					if(text::is_blank(line.data(), line.data() + line.size()))
						return buffer.begin(n+1);
				}
				return 0;
			}
			break;

			case kSelectionMoveToEndOfHardParagraph:
			{
				for(NSUInteger n = line+1; n < buffer.lines(); ++n)
				{
					NSString * line = buffer.substr(buffer.begin(n), buffer.end(n));
					if(text::is_blank(line.data(), line.data() + line.size()))
						return buffer.begin(n);
				}
				return buffer.size();
			}
			break;

			case kSelectionMoveFreehandedLeft:
			{
				if(index.carry != 0)
					return index_t(caret, index.carry - 1);
				else if(caret != 0 && buffer[caret-1] == "\t")
					return at_column(buffer, line, count_columns(buffer, caret) - 1);
				else
					return move(buffer, index, kSelectionMoveLeft, layout); // FIXME With soft tabs this might move a full tab stop.
			}
			break;

			case kSelectionMoveFreehandedRight:
			{
				if(caret == buffer.size() || buffer[caret] == "\n")
					return index_t(caret, index.carry + 1);
				else if(buffer[caret] == "\t")
					return at_column(buffer, line, count_columns(buffer, caret) + index.carry + 1);
				else
					return move(buffer, index, kSelectionMoveRight, layout); // FIXME With soft tabs this might move a full tab stop.
			}
			break;

			case kSelectionMoveToBeginOfWord:
			{
				NSUInteger i = caret;
				NSUInteger bol = buffer.begin(line);
				bol = i == bol && line != 0 ? buffer.begin(line-1) : bol;
				if(i == bol)
					return bol;

				NSString * charType = character_class(buffer, i-1);
				while(bol < i && character_class(buffer, i-1) == charType)
					i -= buffer[i-1].size();

				if((charType == kCharacterClassSpace || charType == kCharacterClassOther) && bol < i && i + buffer[i].size() == caret)
				{
					NSString * charType = character_class(buffer, i-1);
					while(bol < i && character_class(buffer, i-1) == charType)
						i -= buffer[i-1].size();
				}

				return i;
			}
			break;

			case kSelectionMoveToEndOfWord:
			{
				NSUInteger i = caret;
				NSUInteger eol = buffer.eol(line);
				eol = caret == eol && line+1 < buffer.lines() ? buffer.eol(line+1) : eol;
				if(caret == eol)
					return eol;

				NSString * charType = character_class(buffer, i);
				while(i < eol && character_class(buffer, i) == charType)
					i += buffer[i].size();

				if((charType == kCharacterClassSpace || charType == kCharacterClassOther) && i < eol && i == caret + buffer[caret].size())
				{
					charType = character_class(buffer, i);
					while(i < eol && character_class(buffer, i) == charType)
						i += buffer[i].size();
				}

				return i;
			}
			break;

			case kSelectionMoveToBeginOfSubWord:
			{
				static regexp::pattern_t ptrn("(\\p{Upper}\\p{Lower}+|\\p{Upper}+|\\p{Lower}+)[^\\p{Upper}\\p{Lower}]?$|[^\\p{Upper}\\p{Lower}]+$");

				NSUInteger n = line && caret == buffer.begin(line) ? line-1 : line;
				NSString * line = buffer.substr(buffer.begin(n), caret);
				if(regexp::match_t  m = search(ptrn, line.data(), line.data() + line.size()))
					return buffer.begin(n) + m.begin();
			}
			break;

			case kSelectionMoveToEndOfSubWord:
			{
				static regexp::pattern_t ptrn("\\G([^\\p{Upper}\\p{Lower}]?("
					 "\\p{Upper}\\p{Upper}+?(?=\\p{Upper}\\p{Lower})" // NS‸String
					"|\\p{Upper}\\p{Upper}+"                          // NDEBUG‸
					"|\\p{Upper}\\p{Lower}*"                          // Camel‸Case || Camel‸_case
					"|\\p{Lower}+"                                    // camel‸Case || camel‸_case
					")|[^\\p{Upper}\\p{Lower}]*)");                   //    ‸leading_whitespace

				NSUInteger n = line+1 < buffer.lines() && caret == buffer.eol(line) ? line+1 : line;
				NSString * line = buffer.substr(caret, buffer.eol(n));
				if(regexp::match_t  m = search(ptrn, line.data(), line.data() + line.size()))
					return caret + m.end();
			}
			break;

			case kSelectionMoveToBeginOfColumn:
			{
				NSUInteger index = caret;
				if(index == buffer.size() || !is_part_of_word(buffer, index))
				{
					while(buffer.convert(index).column && !is_part_of_word(buffer, index-1))
						index -= buffer[index-1].size();
				}
				while(buffer.convert(index).column && is_part_of_word(buffer, index-1))
					index -= buffer[index-1].size();

				NSUInteger orgCol = count_columns(buffer, caret);
				NSUInteger col    = count_columns(buffer, index);
				NSUInteger n      = line;
				for(; n != 0; --n)
				{
					index_t newIndex = at_column(buffer, n-1, col);
					if(newIndex.carry || (col && is_part_of_word(buffer, newIndex.index-1)) || !is_part_of_word(buffer, newIndex.index))
						break;
				}

				if(n && n == line)
				{
					while(--n != 0)
					{
						index_t newIndex = at_column(buffer, n, orgCol);
						if(!newIndex.carry && ((orgCol && is_part_of_word(buffer, newIndex.index-1)) || is_part_of_word(buffer, newIndex.index)))
							break;
					}
				}

				return at_column(buffer, n, orgCol);
			}
			break;

			case kSelectionMoveToEndOfColumn:
			{
				NSUInteger index = caret;
				if(index == buffer.size() || !is_part_of_word(buffer, index))
				{
					while(buffer.convert(index).column && !is_part_of_word(buffer, index-1))
						index -= buffer[index-1].size();
				}
				while(buffer.convert(index).column && is_part_of_word(buffer, index-1))
					index -= buffer[index-1].size();

				NSUInteger orgCol = count_columns(buffer, caret);
				NSUInteger col    = count_columns(buffer, index);
				NSUInteger n      = line;
				for(; n+1 != buffer.lines(); ++n)
				{
					index_t newIndex = at_column(buffer, n+1, col);
					if(newIndex.carry || newIndex.index == buffer.size() || (col && is_part_of_word(buffer, newIndex.index-1)) || !is_part_of_word(buffer, newIndex.index))
						break;
				}

				if(n+1 != buffer.lines() && n == line)
				{
					while(++n != buffer.lines()-1)
					{
						index_t newIndex = at_column(buffer, n, orgCol);
						if(!newIndex.carry && newIndex.index != buffer.size() && ((orgCol && is_part_of_word(buffer, newIndex.index-1)) || is_part_of_word(buffer, newIndex.index)))
							break;
					}
				}

				return at_column(buffer, n, orgCol);
			}
			break;
		}
		return index;
	}

	ranges_t move (NSString * buffer, ranges_t  selection, move_unit_type const orgUnit, id<OakLayoutMovement> layout)
	{
		static std::set<move_unit_type> const leftward  = { kSelectionMoveLeft,  kSelectionMoveFreehandedRight, kSelectionMoveToBeginOfLine, kSelectionMoveToBeginOfParagraph, kSelectionMoveToBeginOfTypingPair, kSelectionMoveToBeginOfSoftLine, kSelectionMoveToBeginOfSubWord, kSelectionMoveToBeginOfWord };
		static std::set<move_unit_type> const rightward = { kSelectionMoveRight, kSelectionMoveFreehandedLeft, kSelectionMoveToEndOfLine, kSelectionMoveToEndOfParagraph, kSelectionMoveToEndOfTypingPair, kSelectionMoveToEndOfSoftLine, kSelectionMoveToEndOfSubWord, kSelectionMoveToEndOfWord            };

		BOOL isLeftward  = leftward.find(orgUnit)  != leftward.end();
		BOOL isRightward = rightward.find(orgUnit) != rightward.end();

		ranges_t res;
		citerate(range, isLeftward || isRightward ? dissect_columnar(buffer, selection) : selection)
		{
			move_unit_type unit = orgUnit;
			index_t index       = range->last;
			BOOL freehanded     = range->freehanded;

			if(!range->empty())
			{
				if(isLeftward || isRightward)
				{
					index = isLeftward ? range->min() : range->max();

					static std::set<move_unit_type> const left_right = { kSelectionMoveLeft,  kSelectionMoveRight, kSelectionMoveFreehandedRight, kSelectionMoveFreehandedLeft                                                                                                           };
					if(left_right.find(unit) != left_right.end())
						unit = kSelectionMoveNowhere;
				}
				else if(!range->columnar && (unit == kSelectionMoveUp || unit == kSelectionMoveDown) && buffer.convert(range->first.index).line != buffer.convert(range->last.index).line)
				{
					index = unit == kSelectionMoveUp ? range->min() : range->max();
					if(unit == kSelectionMoveDown && buffer.begin(buffer.convert(index.index).line) == index.index)
						unit = kSelectionMoveNowhere;
				}
			}

			if(freehanded)
			{
				if(unit == kSelectionMoveLeft)
					unit = kSelectionMoveFreehandedLeft;
				else if(unit == kSelectionMoveRight)
					unit = kSelectionMoveFreehandedRight;
			}

			switch(unit)
			{
				case kSelectionMoveToBeginOfSelection: index = range->min();                      break;
				case kSelectionMoveToEndOfSelection:   index = range->max();                      break;
				default:                               index = move(buffer, index, unit, layout); break;
			}

			if(freehanded && orgUnit == kSelectionMoveLeft && range->empty() && buffer.convert(index.index).line + 1 == buffer.convert(range->last.index).line)
				freehanded = false;

			res.push_back(range_t(index, index, false, freehanded));
		}

		if(res.size() > 1 && (orgUnit == kSelectionMoveUp || orgUnit == kSelectionMoveDown))
		{
			index_t min(SIZE_T_MAX), max(0);
			iterate(range, res)
			{
				min = MIN(min, range->min());
				max = MAX(max, range->max());
			}
			res = orgUnit == kSelectionMoveUp ? min : max;
		}

		return sanitize(buffer, res);
	}

	// ====================
	// = Extend Selection =
	// ====================

	static range_t extend (NSString * buffer, range_t  range, select_unit_type unit, id<OakLayoutMovement> layout)
	{
		index_t first      = range.first;
		index_t last       = range.last;
		index_t  min = range.min();
		index_t  max = range.max();

		if(first == last && !range.freehanded)
			first.carry = last.carry = 0;

		if(range.unanchored)
		{
			static std::set<select_unit_type> towardBegin = { kSelectionExtendLeft, kSelectionExtendFreehandedLeft, kSelectionExtendUp, kSelectionExtendToBeginOfWord, kSelectionExtendToBeginOfSubWord, kSelectionExtendToBeginOfSoftLine, kSelectionExtendToBeginOfIndentedLine, kSelectionExtendToBeginOfLine, kSelectionExtendToBeginOfParagraph, kSelectionExtendToBeginOfColumn, kSelectionExtendToBeginOfDocument, kSelectionExtendPageUp };
			static std::set<select_unit_type> towardEnd   = { kSelectionExtendRight, kSelectionExtendFreehandedRight, kSelectionExtendDown, kSelectionExtendToEndOfWord, kSelectionExtendToEndOfSubWord, kSelectionExtendToEndOfSoftLine, kSelectionExtendToEndOfIndentedLine, kSelectionExtendToEndOfLine, kSelectionExtendToEndOfParagraph, kSelectionExtendToEndOfColumn, kSelectionExtendToEndOfDocument, kSelectionExtendPageDown };

			if(first < last && towardBegin.find(unit) != towardBegin.end())
				std::swap(first, last);
			else if(last < first && towardEnd.find(unit) != towardEnd.end())
				std::swap(first, last);
		}

		if(range.freehanded || range.columnar)
		{
			if(unit == kSelectionExtendLeft)
				unit = kSelectionExtendFreehandedLeft;
			else if(unit == kSelectionExtendRight)
				unit = kSelectionExtendFreehandedRight;
		}

		switch(unit)
		{
			case kSelectionExtendLeft:                 return range_t(first, move(buffer, last, kSelectionMoveLeft,               layout), range.columnar, range.freehanded);
			case kSelectionExtendRight:                return range_t(first, move(buffer, last, kSelectionMoveRight,              layout), range.columnar, range.freehanded);
			case kSelectionExtendFreehandedLeft:       return range_t(first, move(buffer, last, kSelectionMoveFreehandedLeft,     layout), range.columnar, range.freehanded);
			case kSelectionExtendFreehandedRight:      return range_t(first, move(buffer, last, kSelectionMoveFreehandedRight,    layout), range.columnar, range.freehanded);
			case kSelectionExtendUp:                   return range_t(first, move(buffer, last, kSelectionMoveUp,                 layout), range.columnar, range.freehanded);
			case kSelectionExtendDown:                 return range_t(first, move(buffer, last, kSelectionMoveDown,               layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfWord:        return range_t(first, move(buffer, last, kSelectionMoveToBeginOfWord,      layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfWord:          return range_t(first, move(buffer, last, kSelectionMoveToEndOfWord,        layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfSubWord:     return range_t(first, move(buffer, last, kSelectionMoveToBeginOfSubWord,   layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfSubWord:       return range_t(first, move(buffer, last, kSelectionMoveToEndOfSubWord,     layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfIndentedLine: return range_t(first, move(buffer, last, kSelectionMoveToBeginOfIndentedLine, layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfIndentedLine:  return range_t(first, move(buffer, last, kSelectionMoveToEndOfIndentedLine, layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfSoftLine:    return range_t(first, move(buffer, last, kSelectionMoveToBeginOfSoftLine,  layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfSoftLine:      return range_t(first, move(buffer, last, kSelectionMoveToEndOfSoftLine,    layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfLine:        return range_t(first, move(buffer, last, kSelectionMoveToBeginOfLine,      layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfLine:          return range_t(first, move(buffer, last, kSelectionMoveToEndOfLine,        layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfParagraph:   return range_t(first, move(buffer, last, kSelectionMoveToBeginOfParagraph, layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfParagraph:     return range_t(first, move(buffer, last, kSelectionMoveToEndOfParagraph,   layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfTypingPair:  return range_t(first, move(buffer, last, kSelectionMoveToBeginOfTypingPair, layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfTypingPair:    return range_t(first, move(buffer, last, kSelectionMoveToEndOfTypingPair,  layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfColumn:      return range_t(first, move(buffer, last, kSelectionMoveToBeginOfColumn,    layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfColumn:        return range_t(first, move(buffer, last, kSelectionMoveToEndOfColumn,      layout), range.columnar, range.freehanded);
			case kSelectionExtendToBeginOfDocument:    return range_t(first, move(buffer, last, kSelectionMoveToBeginOfDocument,  layout), range.columnar, range.freehanded);
			case kSelectionExtendToEndOfDocument:      return range_t(first, move(buffer, last, kSelectionMoveToEndOfDocument,    layout), range.columnar, range.freehanded);
			case kSelectionExtendPageUp:               return range_t(first, move(buffer, last, kSelectionMovePageUp,             layout), range.columnar, range.freehanded);
			case kSelectionExtendPageDown:             return range_t(first, move(buffer, last, kSelectionMovePageDown,           layout), range.columnar, range.freehanded);

			case kSelectionExtendToSoftLine:           return range_t(move(buffer, min, kSelectionMoveToBeginOfSoftLine,          layout), min.index != max.index && max.index == move(buffer, max, kSelectionMoveToBeginOfSoftLine, layout).index ? max : move(buffer, move(buffer, max, kSelectionMoveToEndOfSoftLine, layout), kSelectionMoveRight, layout), false, false, true);
			case kSelectionExtendToLine:               return range_t(move(buffer, min, kSelectionMoveToBeginOfLine,              layout), min.index != max.index && buffer.convert(max.index).column == 0 ? max : move(buffer, move(buffer, max, kSelectionMoveToEndOfLine, layout), kSelectionMoveRight, layout), false, false, true);
			case kSelectionExtendToLineExclLF:         return range_t(move(buffer, min, kSelectionMoveToBeginOfLine,              layout), min.index != max.index && buffer.convert(max.index).column == 0 ? max : move(buffer, max, kSelectionMoveToEndOfLine, layout), false, false, true);
			case kSelectionExtendToParagraph:          return range_t(move(buffer, min, kSelectionMoveToBeginOfHardParagraph,     layout), move(buffer, max, kSelectionMoveToEndOfHardParagraph, layout), false, false, true);
			case kSelectionExtendToAll:                return range_t(move(buffer, min, kSelectionMoveToBeginOfDocument,          layout), move(buffer, max, kSelectionMoveToEndOfDocument,  layout), false, false, true);

			case kSelectionExtendToWord:
			{
				NSUInteger from = min.index, to = max.index;
				NSUInteger bol = buffer.begin(buffer.convert(from).line);
				NSUInteger eol = buffer.eol(buffer.convert(to).line);

				NSString * outerLeftType  = from == bol ? kCharacterClassUnknown : character_class(buffer, from-1);
				NSString * innerLeftType  = from == eol ? kCharacterClassUnknown : character_class(buffer, from);
				NSString * innerRightType = to == bol   ? kCharacterClassUnknown : character_class(buffer, to-1);
				NSString * outerRightType = to == eol   ? kCharacterClassUnknown : character_class(buffer, to);

				BOOL extendLeft = false, extendRight = false;

				if(from == to) // no existing selection
				{
					if(outerLeftType == outerRightType)
						extendLeft = extendRight = true;
					else if(outerRightType == kCharacterClassWord || outerLeftType == kCharacterClassSpace || outerLeftType == kCharacterClassUnknown || (outerLeftType == kCharacterClassOther && outerRightType != kCharacterClassSpace && outerRightType != kCharacterClassUnknown))
						extendRight = true;
					else
						extendLeft = true;
				}
				else
				{
					if(outerLeftType == innerLeftType && innerRightType != outerRightType)
						extendLeft = true;
					else if(outerLeftType != innerLeftType && outerRightType == innerRightType)
						extendRight = true;
					else if(outerLeftType == innerLeftType && outerRightType == innerRightType)
						extendLeft = extendRight = true;
				}

				if(extendLeft)
				{
					while(bol < from && character_class(buffer, from-1) == outerLeftType)
						from -= buffer[from-1].size();
				}

				if(extendRight)
				{
					while(to < eol && character_class(buffer, to) == outerRightType)
						to += buffer[to].size();
				}

				return range_t(from, to, range.columnar, false, true);
			}
			break;

			case kSelectionExtendToTypingPair:
			{
				NSUInteger from = begin_of_typing_pair(buffer, min.index, true);
				NSUInteger to   = end_of_typing_pair(buffer, max.index, true);

				if(from != min.index && to != max.index)
				{
					NSUInteger firstLine = buffer.convert(from).line, lastLine = buffer.convert(to).line;
					NSUInteger bol = buffer.begin(firstLine), eol = buffer.end(lastLine);
					return firstLine != lastLine && all_whitespace(buffer, bol, from) && all_whitespace(buffer, to, eol) ? range_t(bol, eol, false, false, true) : range_t(from, to, false, false, true);
				}
			}
			break;

			case kSelectionExtendToScope:
			{
				NSUInteger from = min.index, to = max.index;

				scope::scope_t leftScope  = buffer.scope(from, false).left;
				scope::scope_t rightScope = buffer.scope(to, false).right;
				if(leftScope == rightScope)
				{
					// D(DBF_TextView_Internal, bug("select both sides: %s\n", to_s(leftScope).c_str()););
					from = extend_scope_left(buffer, from, leftScope);
					to   = extend_scope_right(buffer, to, rightScope);
				}
				else if(from != to)
				{
					scope::scope_t innerLeftScope  = buffer.scope(from, false).right;
					scope::scope_t innerRightScope = buffer.scope(to, false).left;

					// D(DBF_TextView_Internal, bug("%s\n", to_s(leftScope).c_str()););
					// D(DBF_TextView_Internal, bug("%s\n", to_s(innerLeftScope).c_str()););
					// D(DBF_TextView_Internal, bug("%s\n", to_s(innerRightScope).c_str()););
					// D(DBF_TextView_Internal, bug("%s\n", to_s(rightScope).c_str()););

					scope::scope_t scope = shared_prefix(shared_prefix(leftScope, innerLeftScope), shared_prefix(rightScope, innerRightScope));
					// D(DBF_TextView_Internal, bug("→ %s\n", to_s(scope).c_str()););

					from = extend_scope_left(buffer, from, scope);
					to   = extend_scope_right(buffer, to, scope);
				}
				else if(leftScope.has_prefix(rightScope))
				{
					while(leftScope.parent() != rightScope)
						leftScope = leftScope.parent();
					// D(DBF_TextView_Internal, bug("select left side: %s\n", to_s(leftScope).c_str()););
					from = extend_scope_left(buffer, from, leftScope);
				}
				else if(rightScope.has_prefix(leftScope))
				{
					while(rightScope.parent() != leftScope)
						rightScope = rightScope.parent();
					// D(DBF_TextView_Internal, bug("select right side: %s\n", to_s(rightScope).c_str()););
					to = extend_scope_right(buffer, to, rightScope);
				}
				else if(from == to && buffer.convert(to).column == 0)
				{
					to = extend_scope_right(buffer, to, rightScope);
				}
				else
				{
					// D(DBF_TextView_Internal, bug("intersection: %s\n           != %s\n", to_s(leftScope).c_str(), to_s(rightScope).c_str()););
					scope::scope_t  scope = shared_prefix(leftScope, rightScope);
					// D(DBF_TextView_Internal, bug("→ %s\n", to_s(scope).c_str()););
					from = extend_scope_left(buffer, from, scope);
					to   = extend_scope_right(buffer, to, scope);
				}
				return range_t(from, to, false, false, true);
			}
			break;
		}
		return range;
	}

	ranges_t extend (NSString * buffer, ranges_t  selection, select_unit_type const unit, id<OakLayoutMovement> layout)
	{
		ranges_t res;
		citerate(range, (unit == kSelectionExtendToWord || unit == kSelectionExtendToTypingPair || unit == kSelectionExtendToScope) ? dissect_columnar(buffer, selection) : selection)
			res.push_back(extend(buffer, *range, unit, layout));
		return sanitize(buffer, res);
	}

	ranges_t extend_if_empty (NSString * buffer, ranges_t  selection, select_unit_type const unit, id<OakLayoutMovement> layout)
	{
		ranges_t res;
		iterate(range, selection)
		{
			if(not_empty(buffer, *range))
			{
				res.push_back(*range);
			}
			else
			{
				citerate(r, dissect_columnar(buffer, *range))
				{
					range_t range = extend(buffer, *r, unit, layout);
					if(unit == kSelectionExtendToEndOfParagraph && range.empty())
						range = extend(buffer, range, kSelectionExtendRight, layout);
					res.push_back(range);
				}
			}
		}
		return sanitize(buffer, res);
	}

	// ================
	// = Select Scope =
	// ================

	static NSUInteger extend_scope_left (NSString * buffer, NSUInteger caret, scope::selector_t  scopeSelector)
	{
		while(caret && scopeSelector.does_match(buffer.scope(caret).left))
			caret -= buffer[caret-1].size();
		return caret;
	}

	static NSUInteger extend_scope_right (NSString * buffer, NSUInteger caret, scope::selector_t  scopeSelector)
	{
		while(caret < buffer.size() && scopeSelector.does_match(buffer.scope(caret).right))
			caret += buffer[caret].size();
		return caret;
	}

	static range_t select_scope (NSString * buffer, range_t  range, scope::selector_t  scopeSelector)
	{
		return range_t(extend_scope_left(buffer, range.min().index, scopeSelector), extend_scope_right(buffer, range.max().index, scopeSelector));
	}

	ranges_t select_scope (NSString * buffer, ranges_t  selection, scope::selector_t  scopeSelector)
	{
		ranges_t res;
		iterate(range, selection)
			res.push_back(select_scope(buffer, *range, scopeSelector));
		return sanitize(buffer, res);
	}

	// ================
	// = Obtain Scope =
	// ================
	
	OakScopeContext * scope (NSString * buffer, ranges_t  selection, NSString * extraAttributes)
	{
		OakScopeContext * res;
		if(selection.size() == 1)
		{
			range_t const range = selection.last();
			if(range.empty())
					res = buffer.scope(range.last.index);
			else	res = shared_prefix(buffer.scope(range.min().index).right, buffer.scope(range.max().index).left);
		}
		else
		{
			scope::scope_t scope;
			citerate(range, selection)
			{
				scope::scope_t newScope = shared_prefix(buffer.scope(range->min().index).right, buffer.scope(range->max().index).left);
				scope = scope ? shared_prefix(scope, newScope) : newScope;
			}
			res = scope;
		}

		if(extraAttributes != NULL_STR)
		{
			citerate(atom, text::tokenize(extraAttributes.begin(), extraAttributes.end(), ' '))
			{
				res.left  = res.left.append(*atom);
				res.right = res.right.append(*atom);
			}
		}

		if(selection.size() > 1)
		{
			res.left  = res.left.append("dyn.caret.mixed");
			res.right = res.right.append("dyn.caret.mixed");
		}
		else if(selection.last().columnar)
		{
			res.left  = res.left.append("dyn.caret.mixed.columnar");
			res.right = res.right.append("dyn.caret.mixed.columnar");
		}
		else
		{
			NSUInteger const leftCaret  = selection.last().min().index;
			NSUInteger const rightCaret = selection.last().max().index;

			if(leftCaret == 0)
				res.left = res.left.append("dyn.caret.begin.document");
			else if(leftCaret == buffer.begin(buffer.convert(leftCaret).line))
				res.left = res.left.append("dyn.caret.begin.line");

			if(rightCaret == buffer.size())
				res.right = res.right.append("dyn.caret.end.document");
			else if(rightCaret == buffer.eol(buffer.convert(rightCaret).line))
				res.right = res.right.append("dyn.caret.end.line");
		}

		if(not_empty(buffer, selection))
		{
			res.left  = res.left.append("dyn.selection");
			res.right = res.right.append("dyn.selection");
		}

		return res;
	}

	// ====================
	// = Highlight Ranges =
	// ====================

	ranges_t highlight_ranges_for_movement (NSString * buffer, ranges_t  oldSelection, ranges_t  newSelection)
	{
		ranges_t res;
		if(oldSelection.size() != newSelection.size())
			return res;

		for(auto oldRange = oldSelection.begin(), newRange = newSelection.begin(); oldRange != oldSelection.end(); ++oldRange, ++newRange)
		{
			if(*oldRange == *newRange || !oldRange->empty() || !newRange->empty())
				continue;

			NSUInteger prevCaret = oldRange->last.index;
			NSUInteger curCaret  = newRange->last.index;
			auto pairs       = character_pairs(buffer.scope(MIN(prevCaret, curCaret)), "highlightPairs");

			if(prevCaret < curCaret && prevCaret + buffer[prevCaret].size() == curCaret) // moved right, check end character
			{
				auto pair = first_match(buffer, prevCaret, pairs);
				if(pair && !pair.matched_first)
				{
					NSUInteger from = begin_of_typing_pair(buffer, prevCaret, true);
					if(from != prevCaret && does_match(buffer, from, pair.first))
						res.push_back(range_t(from, from + pair.first.size()));
				}
			}
			else if(curCaret < prevCaret && curCaret + buffer[curCaret].size() == prevCaret) // moved left, check begin character
			{
				auto pair = first_match(buffer, curCaret, pairs);
				if(pair && pair.matched_first)
				{
					NSUInteger to = end_of_typing_pair(buffer, prevCaret, true);
					if(to != prevCaret && to >= pair.second.size() && does_match(buffer, to - pair.second.size(), pair.second))
						res.push_back(range_t(to - pair.second.size(), to));
				}
			}
		}

		return res;
	}

	// ========
	// = Find =
	// ========

	static BOOL is_subset (range_t  range, ranges_t  ranges)
	{
		iterate(r, ranges)
		{
			if(r->min() <= range.min() && range.max() <= r->max())
				return true;
		}
		return ranges.empty();
	}

	std::map< range_t, std::map<NSString *, NSString *> > find_all (NSString * buffer, NSString * searchFor, NSStringCompareOptions options, ranges_t  searchRanges)
	{
		std::map< range_t, std::map<NSString *, NSString *> > res;
		if(searchFor == NULL_STR || searchFor == "")
			return res;

		ranges_t ranges = dissect_columnar(buffer, searchRanges);
		find::find_t f(searchFor, (NSStringCompareOptions)(options & ~find::backwards));

		ssize_t total = 0;
		iterate(memory, buffer)
		{
			char const* buf = (*memory).data();
			NSUInteger len      = (*memory).size();

			for(ssize_t offset = 0; offset < len; )
			{
				std::map<NSString *, NSString *> captures;
				std::pair<ssize_t, ssize_t>  m = f.match(buf + offset, len - offset, &captures);
				if(m.first <= m.second)
				{
					range_t r(total + offset + m.first, total + offset + m.second, false, false, true);
					if(is_subset(r, ranges))
						res.insert(std::make_pair(r, captures));
				}
				ASSERT_NE(m.second, 0); ASSERT_LE(m.second, len - offset);
				offset += m.second;
			}
			total += len;
		}

		std::map<NSString *, NSString *> captures;
		std::pair<ssize_t, ssize_t> m = f.match(NULL, 0, &captures);
		while(m.first <= m.second)
		{
			range_t r(total + m.first, total + m.second, false, false, true);
			if(is_subset(r, ranges))
				res.insert(std::make_pair(r, captures));
			captures.clear();
			m = f.match(NULL, 0, &captures);
		}

		return res;
	}

	static std::map< range_t, std::map<NSString *, NSString *> > regexp_find (NSString * buffer, NSString * searchFor, NSStringCompareOptions options, NSUInteger first, NSUInteger last)
	{
		std::map< range_t, std::map<NSString *, NSString *> > res;

		OnigOptionType ptrnOptions = ONIG_OPTION_NONE;
		if(options && find::ignore_case)
			ptrnOptions |= ONIG_OPTION_IGNORECASE;

		NSString * str = buffer.substr(0, buffer.size());
		if(regexp::match_t  m = search(regexp::pattern_t(searchFor, ptrnOptions), str.data(), str.data() + str.size(), str.data() + first, str.data() + last))
			res.insert(std::make_pair(ng::range_t(m.begin(), m.end()), m.captures()));

		return res;
	}

	std::map< range_t, std::map<NSString *, NSString *> > find (NSString * buffer, ranges_t  selection, NSString * searchFor, NSStringCompareOptions options, ranges_t  searchRanges)
	{
		std::map< range_t, std::map<NSString *, NSString *> > res;
		if(searchFor == NULL_STR || searchFor == "")
			return res;

		if(selection.size() == 1 && (options & (find::regular_expression|find::wrap_around|find::all_matches|find::extend_selection)) == find::regular_expression)
		{
			NSUInteger first = (options & find::backwards) ? selection.last().min().index : selection.last().max().index;
			NSUInteger last  = (options & find::backwards) ?                            0 :                buffer.size();
			return regexp_find(buffer, searchFor, options, first, last);
		}

		auto tmp = find_all(buffer, searchFor, options, searchRanges);
		if(options & find::all_matches)
			return tmp;

		if(options & find::extend_selection)
		{
			OakSelectionIndex * anchor(options & find::backwards ? buffer.size() : 0);
			iterate(range, selection)
			{
				anchor = options & find::backwards ? MIN(range->min(), anchor) : MAX(range->max(), anchor);
				res.insert(std::make_pair(*range, std::map<NSString *, NSString *>()));
			}

			if(options & find::backwards)
			{
				auto it = tmp.lower_bound(anchor);
				if(it != tmp.begin())
					res.insert(*--it);
			}
			else
			{
				auto it = tmp.upper_bound(anchor);
				if(it != tmp.end())
					res.insert(*it);
			}

			return res;
		}

		citerate(range, dissect_columnar(buffer, selection))
		{
			if(options & find::backwards)
			{
				auto it = tmp.lower_bound(range->min());
				if(it == tmp.begin())
				{
					if(!(options & find::wrap_around) || tmp.empty())
						continue;
					it = --tmp.end();
				}
				else
				{
					--it;
				}

				if(range->sorted() != it->first.sorted())
					res.insert(*it);
			}
			else
			{
				auto it = tmp.upper_bound(range->max());
				if(it == tmp.end() && (options & find::wrap_around))
					it = tmp.begin();

				if(it != tmp.end() && range->sorted() != it->first.sorted())
					res.insert(*it);
			}
		}

		return res;
	}

	// =============
	// = All Words =
	// =============

	ranges_t all_words (NSString * buffer)
	{
		ranges_t res;

		NSString * charType = kCharacterClassOther;
		NSUInteger from = 0;
		for(NSUInteger i = 0; i < buffer.size(); )
		{
			NSString * newCharType = character_class(buffer, i);
			if(charType != newCharType)
			{
				if(charType != kCharacterClassSpace && charType != kCharacterClassOther && from != i)
					res.push_back(range_t(from, i));
				charType = newCharType;
				from = i;
			}
			i += buffer[i].size();
		}

		if(charType != kCharacterClassSpace && charType != kCharacterClassOther && from != buffer.size())
			res.push_back(range_t(from, buffer.size()));

		return res;
	}

	// ==================
	// = to/from string =
	// ==================

	ranges_t from_string (NSString * buffer, NSString * str)
	{
		ranges_t res;
		citerate(range, text::selection_t(str))
			res.push_back(range_t(index_t(buffer.convert(range->from), range->from.offset), index_t(buffer.convert(range->to), range->to.offset), range->columnar, range->from.offset || range->to.offset));
		return res;
	}

	NSString * to_s (NSString * buffer, ranges_t  ranges)
	{
		text::selection_t res;
		iterate(range, ranges)
		{
			text::pos_t from = buffer.convert(range->first.index), to = buffer.convert(range->last.index);
			from.offset = range->freehanded ? range->first.carry : 0;
			to.offset   = range->freehanded ? range->last.carry  : 0;
			res.push_back(OakTextRange *(from, to, range->columnar));
		}
		return res;
	}
