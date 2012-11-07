#include "folds.h"
#include <bundles/wrappers.h>
#include <regexp/indent.h>
#include <text/OakTextCtype.h>

#include <oak/OakAlgorithm.h>


namespace ng
{
	folds_t::folds_t (buffer_t& buffer) : _buffer(buffer) { _buffer.add_callback(this);    }
	folds_t::~folds_t ()                                  { _buffer.remove_callback(this); }

	// =======
	// = API =
	// =======

	NSString * folds_t::folded_as_string () const
	{
		std::vector<NSString *> v;
		iterate(pair, _folded)
			v.push_back(text::format("(%zu,%zu)", pair->first, pair->second));
		return v.empty() ? NULL_STR : "(" + text::join(v, ",") + ")";
	}

	void folds_t::set_folded_as_string (NSString * str)
	{
		id value = plist::parse_ascii(str);
		if(plist::array_t const* array = boost::get<plist::array_t>(&value))
		{
			std::vector< std::pair<NSUInteger, NSUInteger> > newFoldings;
			iterate(pair, *array)
			{
				if(plist::array_t const* value = boost::get<plist::array_t>(&*pair))
				{
					int32_t const* from = value->size() == 2 ? boost::get<int32_t>(&(*value)[0]) : NULL;
					int32_t const* to   = value->size() == 2 ? boost::get<int32_t>(&(*value)[1]) : NULL;
					if(from && to)
						newFoldings.push_back(std::make_pair(*from, *to));
				}
			}
			set_folded(newFoldings);
		}
	}

	// =============
	// = Query API =
	// =============

	bool folds_t::has_folded (NSUInteger n) const
	{
		NSUInteger bol = _buffer.begin(n), eol = _buffer.eol(n);
		iterate(pair, _folded)
		{
			if((pair->first <= bol && bol <= pair->second) || (pair->first <= eol && eol <= pair->second))
				return true;
		}
		return false;
	}

	bool folds_t::has_start_marker (NSUInteger n) const
	{
		auto type = info_for(n).type;
		return type == kLineTypeStartMarker || type == kLineTypeIndentStartMarker;
	}

	bool folds_t::has_stop_marker (NSUInteger n) const
	{
		return info_for(n).type == kLineTypeStopMarker;
	}

	indexed_map_t<bool>  folds_t::folded () const
	{
		return _legacy;
	}

	void folds_t::set_folded (std::vector< std::pair<NSUInteger, NSUInteger> >  newFoldings)
	{
		if(_folded == newFoldings)
			return;

		_folded = newFoldings;
		std::sort(_folded.begin(), _folded.end());

		std::map<NSUInteger, ssize_t> tmp;
		iterate(pair, _folded)
		{
			++tmp[pair->first];
			--tmp[pair->second];
		}

		_legacy.clear();
		ssize_t level = 0;
		iterate(pair, tmp)
		{
			if(pair->second == 0)
				continue;

			if(level == 0 && pair->second > 0)
				_legacy.set(pair->first, true);
			level += pair->second;
			if(level == 0)
				_legacy.set(pair->first, false);
		}
	}

	// ===============
	// = Folding API =
	// ===============

	void folds_t::fold (NSUInteger from, NSUInteger to)
	{
		std::vector< std::pair<NSUInteger, NSUInteger> > newFoldings = _folded;
		newFoldings.push_back(std::make_pair(from, to));
		set_folded(newFoldings);
	}

	std::vector< std::pair<NSUInteger, NSUInteger> > folds_t::remove_enclosing (NSUInteger from, NSUInteger to)
	{
		std::vector< std::pair<NSUInteger, NSUInteger> > res, newFoldings;

		iterate(pair, _folded)
		{
			if((pair->first <= from && from < pair->second) || (pair->first < to && to <= pair->second))
					res.push_back(*pair);
			else	newFoldings.push_back(*pair);
		}

		set_folded(newFoldings);
		return res;
	}

	std::pair<NSUInteger, NSUInteger> folds_t::toggle_at_line (NSUInteger n, bool recursive)
	{
		std::pair<NSUInteger, NSUInteger> res(0, 0);

		if(has_folded(n))
		{
			NSUInteger bol = _buffer.begin(n), eol = _buffer.eol(n);
			std::vector< std::pair<NSUInteger, NSUInteger> > newFoldings;
			iterate(pair, _folded)
			{
				if(OakCap(pair->first, bol, pair->second) == bol || OakCap(pair->first, eol, pair->second) == eol)
				{
					if(res.first == res.second)
						res = *pair;
				}
				else if(!recursive || !(res.first <= pair->first && pair->second <= res.second))
				{
					newFoldings.push_back(*pair);
				}
			}
			set_folded(newFoldings);
		}
		else
		{
			res = foldable_range_at_line(n);
			if(res.first < res.second)
			{
				if(recursive)
				{
					citerate(pair, foldable_ranges())
					{
						if(res.first <= pair->first && pair->second <= res.second)
							fold(pair->first, pair->second);
					}
				}
				else
				{
					fold(res.first, res.second);
				}
			}
		}

		return res;
	}

	std::vector< std::pair<NSUInteger, NSUInteger> > folds_t::toggle_all_at_level (NSUInteger level)
	{
		std::vector< std::pair<NSUInteger, NSUInteger> >  folded = _folded;

		std::vector< std::pair<NSUInteger, NSUInteger> > unfolded, canFoldAtLevel, foldedAtLevel, nestingStack;
		citerate(pair, foldable_ranges())
		{
			while(!nestingStack.empty() && nestingStack.back().second <= pair->first)
				nestingStack.pop_back();
			nestingStack.push_back(*pair);

			if(level == 0 || level == nestingStack.size())
				unfolded.push_back(*pair);
		}

		std::sort(unfolded.begin(), unfolded.end());
		std::set_difference(unfolded.begin(), unfolded.end(), folded.begin(), folded.end(), back_inserter(canFoldAtLevel));
		std::set_intersection(unfolded.begin(), unfolded.end(), folded.begin(), folded.end(), back_inserter(foldedAtLevel));

		if(canFoldAtLevel.size() >= foldedAtLevel.size())
		{
			iterate(pair, canFoldAtLevel)
				fold(pair->first, pair->second);
			return canFoldAtLevel;
		}

		std::vector< std::pair<NSUInteger, NSUInteger> > newFoldings;
		std::set_difference(folded.begin(), folded.end(), foldedAtLevel.begin(), foldedAtLevel.end(), back_inserter(newFoldings));
		set_folded(newFoldings);
		return foldedAtLevel;
	}

	// ===================
	// = Buffer Callback =
	// ===================

	void folds_t::will_replace (NSUInteger from, NSUInteger to, NSString * str)
	{
		std::vector< std::pair<NSUInteger, NSUInteger> > newFoldings;
		ssize_t delta = str.size() - (to - from);
		iterate(pair, _folded)
		{
			ssize_t foldFrom = pair->first, foldTo = pair->second;
			if(to <= foldFrom)
				newFoldings.push_back(std::make_pair(foldFrom + delta, foldTo + delta));
			else if(foldFrom <= from && to <= foldTo && delta != foldFrom - foldTo)
				newFoldings.push_back(std::make_pair(foldFrom, foldTo + delta));
			else if(foldTo <= from)
				newFoldings.push_back(std::make_pair(foldFrom, foldTo));
		}
		set_folded(newFoldings);

		NSUInteger bol = _buffer.begin(_buffer.convert(from).line);
		NSUInteger end = _buffer.begin(_buffer.convert(to).line);
		auto first = _levels.lower_bound(bol, &key_comp);
		auto last  = _levels.upper_bound(end, &key_comp);
		if(last != _levels.end())
		{
			ssize_t eraseFrom = first->offset;
			ssize_t eraseTo   = last->offset;
			ssize_t diff = (eraseTo - eraseFrom) + str.size() - (to - from);
			last->key += diff;
			_levels.update_key(last);
		}
		_levels.erase(first, last);
	}

	void folds_t::did_parse (NSUInteger from, NSUInteger to)
	{
		NSUInteger bol = _buffer.begin(_buffer.convert(from).line);
		NSUInteger end = _buffer.begin(_buffer.convert(to).line);
		auto first = _levels.lower_bound(bol, &key_comp);
		auto last  = _levels.upper_bound(end, &key_comp);
		if(last != _levels.end())
		{
			last->key += last->offset - first->offset;
			_levels.update_key(last);
		}
		_levels.erase(first, last);
	}

	bool folds_t::integrity () const
	{
		iterate(info, _levels)
		{
			NSUInteger pos = info->offset + info->key;
			if(_buffer.size() < pos || _buffer.convert(pos).column != 0)
			{
				NSUInteger n = _buffer.convert(pos).line;
				fprintf(stderr, "%zu) pos: %zu, line %zu-%zu\n", n+1, pos, _buffer.begin(n), _buffer.eol(n));
				return false;
			}
		}
		return true;
	}

	// ============
	// = Internal =
	// ============

	std::vector< std::pair<NSUInteger, NSUInteger> > folds_t::foldable_ranges () const
	{
		std::vector< std::pair<NSUInteger, NSUInteger> > res;

		std::vector< std::pair<NSUInteger, int> > regularStack;
		std::vector< std::pair<NSUInteger, int> > indentStack;
		for(NSUInteger n = 0; n < _buffer.lines(); ++n)
		{
			value_t info = info_for(n);

			while(!indentStack.empty() && info.type != kLineTypeEmpty && info.type != kLineTypeIgnoreLine && info.indent <= indentStack.back().second)
			{
				if(indentStack.back().first < _buffer.eol(n-1))
					res.push_back(std::make_pair(indentStack.back().first, _buffer.eol(n-1)));
				indentStack.pop_back();
			}

			switch(info.type)
			{
				case kLineTypeStartMarker:       regularStack.push_back(std::make_pair(_buffer.eol(n), info.indent)); break;
				case kLineTypeIndentStartMarker: indentStack.push_back(std::make_pair(_buffer.eol(n), info.indent));  break;

				case kLineTypeStopMarker:
				{
					for(NSUInteger i = regularStack.size(); i > 0; --i)
					{
						if(regularStack[i-1].second == info.indent)
						{
							NSUInteger last = _buffer.begin(n);
							while(last < _buffer.size() && (_buffer[last] == "\t" || _buffer[last] == " "))
								++last;
							res.push_back(std::make_pair(regularStack[i-1].first, last));
							regularStack.resize(i-1);
							break;
						}
					}
				}
				break;
			}
		}

		for(NSUInteger i = indentStack.size(); i > 0; --i)
			res.push_back(std::make_pair(indentStack[i-1].first, _buffer.size()));

		std::sort(res.begin(), res.end());

		std::vector< std::pair<NSUInteger, NSUInteger> > nestingStack, unique;
		citerate(pair, res)
		{
			while(!nestingStack.empty() && nestingStack.back().second <= pair->first)
				nestingStack.pop_back();
			if(!nestingStack.empty() && nestingStack.back().second < pair->second)
				continue;
			nestingStack.push_back(*pair);
			unique.push_back(*pair);
		}
		return unique;
	}

	std::pair<NSUInteger, NSUInteger> folds_t::foldable_range_at_line (NSUInteger n) const
	{
		std::pair<NSUInteger, NSUInteger> res(0, 0);

		NSUInteger bol = _buffer.begin(n), eol = _buffer.eol(n);
		citerate(pair, foldable_ranges())
		{
			if(OakCap(pair->first, bol, pair->second) == bol || OakCap(pair->first, eol, pair->second) == eol)
				res = *pair;
		}
		return res;
	}

	static void setup_patterns (NSString *  buffer, NSUInteger line, NSRegularExpression * startPattern, NSRegularExpression * stopPattern, NSRegularExpression * indentPattern, NSRegularExpression * ignorePattern)
	{
		id ptrn;

		OakBundleItem * didFindPatterns;
		OakScopeContext * scope(buffer.scope(buffer.begin(line), false).right, buffer.scope(buffer.end(line), false).left);
		ptrn = bundles::value_for_setting("foldingStartMarker", scope, &didFindPatterns);
		if(NSString * str = boost::get<NSString *>(&ptrn))
			startPattern = *str;

		ptrn = bundles::value_for_setting("foldingStopMarker", scope);
		if(NSString * str = boost::get<NSString *>(&ptrn))
			stopPattern = *str;

		ptrn = bundles::value_for_setting("foldingIndentedBlockStart", scope);
		if(NSString * str = boost::get<NSString *>(&ptrn))
			indentPattern = *str;

		ptrn = bundles::value_for_setting("foldingIndentedBlockIgnore", scope);
		if(NSString * str = boost::get<NSString *>(&ptrn))
			ignorePattern = *str;

		if(!didFindPatterns) // legacy — this has bad performance
		{
			citerate(item, bundles::query(bundles::kFieldGrammarScope, to_s(buffer.scope(0, false).left), scope::wildcard, bundles::kItemTypeGrammar))
			{
				NSString * foldingStartMarker = NULL_STR, foldingStopMarker = NULL_STR;
				plist::get_key_path((*item)->plist(), "foldingStartMarker", foldingStartMarker);
				plist::get_key_path((*item)->plist(), "foldingStopMarker", foldingStopMarker);
				startPattern = foldingStartMarker;
				stopPattern  = foldingStopMarker;
			}
		}
	}

	folds_t::value_t folds_t::info_for (NSUInteger n) const
	{
		NSUInteger bol = _buffer.begin(n);
		auto it = _levels.lower_bound(bol, &key_comp);
		if(it == _levels.end() || it->offset + it->key != bol)
		{
			if(it != _levels.end())
			{
				bol -= it->offset;
				it->key -= bol;
				_levels.update_key(it);
			}
			else if(it != _levels.begin())
			{
				auto tmp = it;
				--tmp;
				bol -= tmp->offset + tmp->key;
			}

			regexp::pattern_t startPattern, stopPattern, indentPattern, ignorePattern;
			setup_patterns(_buffer, n, startPattern, stopPattern, indentPattern, ignorePattern);

			NSString * line = _buffer.substr(_buffer.begin(n), _buffer.eol(n));
			NSUInteger res = text::is_blank(line.data(), line.data() + line.size())          ?  1 : 0;
			res += regexp::search(startPattern,  line.data(), line.data() + line.size()) ?  2 : 0;
			res += regexp::search(stopPattern,   line.data(), line.data() + line.size()) ?  4 : 0;
			res += regexp::search(indentPattern, line.data(), line.data() + line.size()) ?  8 : 0;
			res += regexp::search(ignorePattern, line.data(), line.data() + line.size()) ? 16 : 0;

			if(res & 6) // if start/stop marker we ignore indent patterns
				res &= ~24;

			auto type  = (res & 1) ? kLineTypeEmpty : kLineTypeRegular;
			switch(res)
			{
				case  2: type = kLineTypeStartMarker;       break;
				case  4: type = kLineTypeStopMarker;        break;
				case  8: type = kLineTypeIndentStartMarker; break;
				case 16: type = kLineTypeIgnoreLine;        break;
			}

			int indent = indent::leading_whitespace(line.data(), line.data() + line.size(), _buffer.indent().tab_size());
			it = _levels.insert(it, bol, value_t(indent, type));
		}
		return it->value;
	}

} /* ng */
