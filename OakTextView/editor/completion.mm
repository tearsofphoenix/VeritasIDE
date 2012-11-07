#include "editor.h"
#include "write.h"
#include <text/utf8.h>
#include <text/classification.h>
#include <text/OakTextCtype.h>
#include <text/tokenize.h>



template <typename _OutputIter>
_OutputIter words_with_prefix_and_suffix (NSString *  buffer, NSString * prefix, NSString * suffix, NSString * excludeWord, _OutputIter out)
{
	citerate(pair, ng::find_all(buffer, prefix.size() < suffix.size() ? suffix : prefix, ))
	{
		ng::range_t range = ng::extend(buffer, pair->first, kSelectionExtendToWord).last();
		NSUInteger bow = range.min().index, eow = range.max().index;
		if(prefix.size() < (eow - bow) && prefix == buffer.substr(bow, bow + prefix.size()) && suffix.size() < (eow - bow) && suffix == buffer.substr(eow - suffix.size(), eow) && excludeWord != buffer.substr(bow, eow))
			*out++ = std::make_pair(bow, buffer.substr(bow, eow));
	}
	return out;
}

namespace ng
{
	struct completion_command_delegate_t : command::delegate_t
	{
		completion_command_delegate_t (NSString *  buffer, OakSelectionRanges *  ranges) : buffer(buffer), ranges(ranges), result(NULL_STR) { }

		OakTextRange * write_unit_to_fd (int fd, input::type unit, input::type fallbackUnit, input_format::type format, scope::selector_t  scopeSelector, std::map<NSString *, NSString *>& variables, bool* inputWasSelection)
		{
			return ng::write_unit_to_fd(buffer, ranges.last(), buffer.indent().tab_size(), fd, unit, fallbackUnit, format, scopeSelector, variables, inputWasSelection);
		}

		bool accept_html_data (command::runner_ptr runner, char const* data, NSUInteger len) { return fprintf(stderr, "html: %.*s", (int)len, data), false; }

		void show_document (NSString * str) { fprintf(stderr, "document: %s\n", str.c_str()); }
		void show_tool_tip (NSString * str) { fprintf(stderr, "tool tip: %s\n", str.c_str()); }
		void show_error (bundle_command_t  command, int rc, NSString * out, NSString * err) { fprintf(stderr, "error: %s%s\n", out.c_str(), err.c_str()); }

		bool accept_result (NSString * out, output::type placement, output_format::type format, output_caret::type outputCaret, OakTextRange * inputRange, std::map<NSString *, NSString *>  environment)
		{
			if(placement == output::replace_selection && format == output_format::completion_list)
				result = out;
			return true;
		}

		NSString *  buffer;
		OakSelectionRanges * ranges;
		NSString * result;
	};

	typedef std::shared_ptr<completion_command_delegate_t> completion_command_delegate_ptr;

	std::vector<NSString *> editor_t::completions (NSUInteger bow, NSUInteger eow, NSString * prefix, NSString * suffix, NSString * scopeAttributes)
	{
		NSString * currentWord = _buffer.substr(bow, eow);
		OakScopeContext * const scope = this->scope(scopeAttributes);

		std::vector< std::pair<NSUInteger, NSString *> > tmp;
		std::vector<NSString *> commandResult;

		// ====================================
		// = Run Potential Completion Command =
		// ====================================

		OakBundleItem * item;
		id value = bundles::value_for_setting("completionCommand", scope, &item);
		if(NSString * str = boost::get<NSString *>(&value))
		{
			bundle_command_t cmd;
			cmd.command       = *str;
			cmd.name          = item->name();
			cmd.uuid          = item->uuid();
			cmd.input         = input::entire_document;
			cmd.input_format  = input_format::text;
			cmd.output        = output::replace_selection;
			cmd.output_format = output_format::completion_list;

			std::map<NSString *, NSString *> env = variables(item->environment(), scopeAttributes);
			env["TM_CURRENT_WORD"] = prefix;
			completion_command_delegate_ptr delegate(new completion_command_delegate_t(_buffer, _selections));
			command::runner_ptr runner = command::runner(cmd, _buffer, _selections, env, delegate);
			runner->launch();
			runner->wait();

			if(delegate->result != NULL_STR)
			{
				citerate(line, text::tokenize(delegate->result.begin(), delegate->result.end(), '\n'))
				{
					if(!(*line).empty())
						commandResult.push_back(*line);
				}
			}
		}

		for(ssize_t i = 0; i < commandResult.size(); ++i)
			tmp.push_back(std::make_pair(-commandResult.size() + i, commandResult[i]));

		// =============================
		// = Collect Words from Buffer =
		// =============================

		if(!plist::is_true(bundles::value_for_setting("disableDefaultCompletion", scope, &item)))
		{
			NSUInteger cnt = tmp.size();
			words_with_prefix_and_suffix(_buffer, prefix, suffix, currentWord, back_inserter(tmp));
			if(cnt == tmp.size())
				words_with_prefix_and_suffix(_buffer, prefix, "", currentWord, back_inserter(tmp));
		}

		// ===============================================
		// = Add Fallback Values from Bundle Preferences =
		// ===============================================

		id completionsValue = bundles::value_for_setting("completions", scope, &item);
		if(plist::array_t const* completions = boost::get<plist::array_t>(&completionsValue))
		{
			for(NSUInteger i = 0; i < completions->size(); ++i)
			{
				if(NSString * word = boost::get<NSString *>(&(*completions)[i]))
					tmp.push_back(std::make_pair(SSIZE_MAX - completions->size() + i, *word));
			}
		}

		// ===============================================

		std::map<NSString *, ssize_t> ranked;
		iterate(pair, tmp)
		{
			NSString * word = pair->second;

			bool hasPrefix = prefix.empty() || (prefix.size() < word.size() && word.find(prefix) == 0);
			bool hasSuffix = hasPrefix && !suffix.empty() && suffix.size() < word.size() && word.find(suffix, word.size() - suffix.size()) == word.size() - suffix.size();
			if(!hasPrefix || word == currentWord)
				continue;

			ssize_t rank = bow <= pair->first ? pair->first - bow : bow - (pair->first + word.size());
			word = word.substr(prefix.size(), word.size() - prefix.size() - (hasSuffix ? suffix.size() : 0));

			auto it = ranked.find(word);
			if(it != ranked.end())
					it->second = MIN(rank, it->second);
			else	ranked.insert(std::make_pair(word, rank));
		}

		std::map<ssize_t, NSString *> ordered;
		iterate(pair, ranked)
			ordered.insert(std::make_pair(pair->second, pair->first));

		std::vector<NSString *> res;
		std::transform(ordered.begin(), ordered.end(), back_inserter(res), [](std::pair<ssize_t, NSString *>  p){ return p.second; });
		return res;
	}

	bool editor_t::setup_completion (NSString * scopeAttributes)
	{
		completion_info_t& info = _completion_info;
		if(info.revision() != _buffer.revision() || info.ranges() != _selections)
		{
			info.set_revision(_buffer.revision());
			info.set_ranges(_selections);

			info.set_prefix_ranges(dissect_columnar(_buffer, _selections));
			ng::range_t r = info.prefix_ranges().last();
			NSUInteger from = r.min().index, to = r.max().index;
			r = ng::extend(_buffer, r, kSelectionExtendToWord).last();
			NSUInteger bow = r.min().index, eow = r.max().index;

			info.set_suggestions(completions(bow, eow, _buffer.substr(bow, from), _buffer.substr(to, eow), scopeAttributes));
		}
		return !info.suggestions().empty();
	}

	void editor_t::next_completion (NSString * scopeAttributes)
	{
		if(setup_completion(scopeAttributes))
		{
			completion_info_t& info = _completion_info;
			info.advance();

			std::multimap<range_t, NSString *> insertions;
			citerate(range, info.prefix_ranges())
				insertions.insert(std::make_pair(*range, info.current()));
			info.set_prefix_ranges(this->replace(insertions, true));
			info.set_revision(_buffer.next_revision());
			info.set_ranges(ng::move(_buffer, info.prefix_ranges(), kSelectionMoveToEndOfSelection));
			_selections = info.ranges();
		}
	}

	void editor_t::previous_completion (NSString * scopeAttributes)
	{
		if(setup_completion(scopeAttributes))
		{
			completion_info_t& info = _completion_info;
			info.retreat();

			std::multimap<range_t, NSString *> insertions;
			citerate(range, info.prefix_ranges())
				insertions.insert(std::make_pair(*range, info.current()));
			info.set_prefix_ranges(this->replace(insertions, true));
			info.set_revision(_buffer.next_revision());
			info.set_ranges(ng::move(_buffer, info.prefix_ranges(), kSelectionMoveToEndOfSelection));
			_selections = info.ranges();
		}
	}

} /* ng */
