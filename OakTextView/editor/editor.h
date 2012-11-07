#ifndef EDITOR_H_GWYNAZT0
#define EDITOR_H_GWYNAZT0

#include "clipboard.h"
#include "snippets.h"




#include <document/document.h>
#include <layout/layout.h>

namespace ng
{
	enum action_t
	{
		kMoveBackward,
		kMoveBackwardAndModifySelection,
		kMoveDown,
		kMoveDownAndModifySelection,
		kMoveForward,
		kMoveForwardAndModifySelection,
		kMoveParagraphBackwardAndModifySelection,
		kMoveParagraphForwardAndModifySelection,
		kMoveSubWordLeft,
		kMoveSubWordLeftAndModifySelection,
		kMoveSubWordRight,
		kMoveSubWordRightAndModifySelection,
		kMoveToBeginningOfColumn,
		kMoveToBeginningOfColumnAndModifySelection,
		kMoveToBeginningOfDocument,
		kMoveToBeginningOfDocumentAndModifySelection,
		kMoveToBeginningOfIndentedLine,
		kMoveToBeginningOfIndentedLineAndModifySelection,
		kMoveToBeginningOfLine,
		kMoveToBeginningOfLineAndModifySelection,
		kMoveToBeginningOfParagraph,
		kMoveToBeginningOfParagraphAndModifySelection,
		kMoveToBeginningOfBlock,
		kMoveToBeginningOfBlockAndModifySelection,
		kMoveToEndOfColumn,
		kMoveToEndOfColumnAndModifySelection,
		kMoveToEndOfDocument,
		kMoveToEndOfDocumentAndModifySelection,
		kMoveToEndOfIndentedLine,
		kMoveToEndOfIndentedLineAndModifySelection,
		kMoveToEndOfLine,
		kMoveToEndOfLineAndModifySelection,
		kMoveToEndOfParagraph,
		kMoveToEndOfParagraphAndModifySelection,
		kMoveToEndOfBlock,
		kMoveToEndOfBlockAndModifySelection,
		kMoveUp,
		kMoveUpAndModifySelection,
		kMoveWordBackward,
		kMoveWordBackwardAndModifySelection,
		kMoveWordForward,
		kMoveWordForwardAndModifySelection,

		kPageDown,
		kPageDownAndModifySelection,
		kPageUp,
		kPageUpAndModifySelection,

		kSelectAll,
		kSelectCurrentScope,
		kSelectBlock,
		kSelectHardLine,
		kSelectLine,
		kSelectParagraph,
		kSelectWord,
		kToggleColumnSelection,

		kFindNext,
		kFindPrevious,
		kFindNextAndModifySelection,
		kFindPreviousAndModifySelection,
		kFindAll,
		kFindAllInSelection,

		kReplace,
		kReplaceAll,
		kReplaceAllInSelection,

		kReplaceAndFind,

		kDeleteBackward,
		kDeleteForward,
		kDeleteSubWordLeft,
		kDeleteSubWordRight,
		kDeleteToBeginningOfIndentedLine,
		kDeleteToBeginningOfLine,
		kDeleteToBeginningOfParagraph,
		kDeleteToEndOfIndentedLine,
		kDeleteToEndOfLine,
		kDeleteToEndOfParagraph,
		kDeleteWordBackward,
		kDeleteWordForward,
		kDeleteBackwardByDecomposingPreviousCharacter,
		kDeleteSelection,

		kCut,
		kCopy,
		kCopySelectionToFindPboard,
		kCopySelectionToReplacePboard,
		kCopySelectionToYankPboard,
		kAppendSelectionToYankPboard,
		kPrependSelectionToYankPboard,
		kPaste,
		kPastePrevious,
		kPasteNext,
		kPasteWithoutReindent,
		kYank,

		kCapitalizeWord,
		kChangeCaseOfLetter,
		kChangeCaseOfWord,
		kLowercaseWord,
		kReformatText,
		kReformatTextAndJustify,
		kShiftLeft,
		kShiftRight,
		kTranspose,
		kTransposeWords,
		kUnwrapText,
		kUppercaseWord,

		kSetMark,
		kDeleteToMark,
		kSelectToMark,
		kSwapWithMark,

		kComplete,
		kNextCompletion,
		kPreviousCompletion,

		kInsertBacktab,
		kInsertTab,
		kInsertTabIgnoringFieldEditor,
		kInsertNewline,
		kInsertNewlineIgnoringFieldEditor,

		kIndent,

		kMoveSelectionUp,
		kMoveSelectionDown,
		kMoveSelectionLeft,
		kMoveSelectionRight,

		kNop
	};

	extern action_t to_action (NSString * sel);

	struct extern editor_t
	{
		editor_t ();
		editor_t (buffer_t& buffer);
		editor_t (document::OakDocument * document);

		void perform (action_t action, layout_t const* layout = NULL, bool indentCorrections = false, NSString * scopeAttributes = NULL_STR);

		bool disallow_tab_expansion () const;

		void insert (NSString * str, bool selectInsertion = false);
		void insert_with_pairing (NSString * str, bool indentCorrections = false, NSString * scopeAttributes = NULL_STR);
		void move_selection_to (ng::index_t  index, bool selectInsertion = true);
		ranges_t replace (NSString * searchFor, NSString * replaceWith, NSStringCompareOptions options = , bool searchOnlySelection = false);
		void delete_tab_trigger (NSString * str);

		void macro_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);
		void find_dispatch (NSMutableDictionary *  args);
		void snippet_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);
		void execute_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);

		OakScopeContext * scope (NSString * scopeAttributes) const;
		std::map<NSString *, NSString *> variables (std::map<NSString *, NSString *> map, NSString * scopeAttributes) const;

		std::vector<NSString *>  choices () const;
		NSString * placeholder_content (ng::range_t* placeholderSelection = NULL) const;
		void set_placeholder_content (NSString * str, NSUInteger selectFrom);

		ranges_t ranges () const                                              { return _selections; }
		void set_selections (ranges_t  r)                               { _selections = r; }
		bool has_selection () const                                           { return not_empty(_buffer, _selections); }
		NSString * as_string (NSUInteger from = 0, NSUInteger to = SIZE_T_MAX) const { return _buffer.substr(from, to != SIZE_T_MAX ? to : _buffer.size()); }

		void perform_replacements (std::multimap<OakTextRange *, NSString *>  replacements);
		bool handle_result (NSString * out, output::type placement, output_format::type format, output_caret::type outputCaret, OakTextRange * input_range, std::map<NSString *, NSString *> environment);

		// ==============
		// = Clipboards =
		// ==============

		clipboard_ptr clipboard () const              { assert(_clipboard);           return _clipboard; }
		clipboard_ptr find_clipboard () const         { assert(_find_clipboard);      return _find_clipboard; }
		clipboard_ptr replace_clipboard () const      { assert(_replace_clipboard);   return _replace_clipboard; }
		clipboard_ptr yank_clipboard () const         { assert(_yank_clipboard); return _yank_clipboard; }

		void set_clipboard (clipboard_ptr cb)         { _clipboard = cb; }
		void set_find_clipboard (clipboard_ptr cb)    { _find_clipboard = cb; }
		void set_replace_clipboard (clipboard_ptr cb) { _replace_clipboard = cb; }
		void set_yank_clipboard (clipboard_ptr cb)    { _yank_clipboard = cb; }

	private:
		void setup ();
		friend struct indent_helper_t;

		static NSUInteger visual_distance (NSString *  buffer, index_t first, index_t last, bool eastAsianWidth = true);
		static index_t visual_advance (NSString *  buffer, index_t caret, NSUInteger distance, bool eastAsianWidth = true);

		static OakSelectionRanges * insert_tab_with_indent (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets);
		static OakSelectionRanges * insert_newline_with_indent (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets);

		static clipboard_t::entry_ptr copy (NSString *  buffer, OakSelectionRanges *  selections);
		static OakSelectionRanges * paste (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets, clipboard_t::entry_ptr entry);

		// ==============
		// = Completion =
		// ==============

		struct completion_info_t
		{
			NSUInteger revision () const                                           { return _revision; }
			void set_revision (NSUInteger rev)                                     { _revision = rev;  }

			OakSelectionRanges *  ranges () const                                { return _ranges;      }
			void set_ranges (OakSelectionRanges *  ranges)                       { _ranges = ranges; }

			OakSelectionRanges *  prefix_ranges () const                         { return _prefix_ranges;   }
			void set_prefix_ranges (OakSelectionRanges *  prefixRanges)          { _prefix_ranges = prefixRanges; }

			std::vector<NSString *>  suggestions () const               { return _suggestions; }
			void set_suggestions (std::vector<NSString *>  suggestions) { _suggestions = suggestions; _index = _suggestions.size(); }

			NSString * current () const                                { ASSERT_LT(_index, _suggestions.size()); return _suggestions[_index]; }

			void advance ()                                                    { if(++_index >= _suggestions.size()) _index = 0;  }
			void retreat ()                                                    { if(--_index < 0) _index = _suggestions.size()-1; }

      private:
			NSUInteger _revision = 0;
			OakSelectionRanges * _ranges;

			OakSelectionRanges * _prefix_ranges;
			std::vector<NSString *> _suggestions;

			ssize_t _index = 0;
		};

		std::vector<NSString *> completions (NSUInteger bow, NSUInteger eow, NSString * prefix, NSString * suffix, NSString * scopeAttributes);
		bool setup_completion (NSString * scopeAttributes);
		void next_completion (NSString * scopeAttributes);
		void previous_completion (NSString * scopeAttributes);

		// ============
		// = Snippets =
		// ============

		void snippet (NSString * str, std::map<NSString *, NSString *>  variables);
		ranges_t snippet (NSUInteger from, NSUInteger to, NSString * str, std::map<NSString *, NSString *>  variables);

		void find (NSString * searchFor, NSStringCompareOptions options = , bool searchOnlySelection = false);
		ranges_t replace (std::multimap<range_t, NSString *>  replacements, bool selectInsertions = false);
		void move_selection (int deltaX, int deltaY);

		// ===============
		// = Member data =
		// ===============

		buffer_t& _buffer;
		OakSelectionRanges * _selections = ranges_t(0);
		snippet_controller_t _snippets;

		completion_info_t _completion_info;

		clipboard_ptr _clipboard;
		clipboard_ptr _find_clipboard;
		clipboard_ptr _replace_clipboard;
		clipboard_ptr _yank_clipboard;
		bool _extend_yank_clipboard = false;

		document::OakDocument * _document;
	};

	typedef std::shared_ptr<editor_t> editor_ptr;

	extern editor_ptr editor_for_document (document::OakDocument * document);

} /* ng */

#endif /* end of include guard: EDITOR_H_GWYNAZT0 */
