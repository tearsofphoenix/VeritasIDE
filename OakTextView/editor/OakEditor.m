//
//  OakEditor.m
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakEditor.h"
#import "OakDocument.h"

@implementation OakEditor

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (id)initWithBuffer: (NSString *)buffer
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (id)initWithDocument: (OakDocument *)document
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (void)performAction: (action_t)action
layout: (OakL)


void perform (action_t action, layout_t const* layout = NULL, BOOL indentCorrections = false, NSString * scopeAttributes = NULL_STR);
        
		BOOL disallow_tab_expansion () ;
        
		void insert (NSString * str, BOOL selectInsertion = false);
		void insert_with_pairing (NSString * str, BOOL indentCorrections = false, NSString * scopeAttributes = NULL_STR);
		void move_selection_to (OakSelectionIndex *  index, BOOL selectInsertion = true);
		ranges_t replace (NSString * searchFor, NSString * replaceWith, NSStringCompareOptions options = , BOOL searchOnlySelection = false);
		void delete_tab_trigger (NSString * str);
        
		void macro_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);
		void find_dispatch (NSMutableDictionary *  args);
		void snippet_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);
		void execute_dispatch (NSMutableDictionary *  args, std::map<NSString *, NSString *>  variables);
        
		OakScopeContext * scope (NSString * scopeAttributes) ;
		std::map<NSString *, NSString *> variables (std::map<NSString *, NSString *> map, NSString * scopeAttributes) ;
        
		std::vector<NSString *>  choices () ;
		NSString * placeholder_content (ng::range_t* placeholderSelection = NULL) ;
		void set_placeholder_content (NSString * str, NSUInteger selectFrom);
        
		ranges_t ranges () const                                              { return _selections; }
		void set_selections (ranges_t  r)                               { _selections = r; }
		BOOL has_selection () const                                           { return not_empty(_buffer, _selections); }
		NSString * as_string (NSUInteger from = 0, NSUInteger to = SIZE_T_MAX) const { return _buffer.substr(from, to != SIZE_T_MAX ? to : _buffer.size()); }
        
		void perform_replacements (std::multimap<OakTextRange *, NSString *>  replacements);
		BOOL handle_result (NSString * out, output::type placement, output_format::type format, output_caret::type outputCaret, OakTextRange * input_range, std::map<NSString *, NSString *> environment);
        
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
        
		static NSUInteger visual_distance (NSString *  buffer, index_t first, index_t last, BOOL eastAsianWidth = true);
		static index_t visual_advance (NSString *  buffer, index_t caret, NSUInteger distance, BOOL eastAsianWidth = true);
        
		static OakSelectionRanges * insert_tab_with_indent (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets);
		static OakSelectionRanges * insert_newline_with_indent (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets);
        
		static clipboard_t::entry_ptr copy (NSString *  buffer, OakSelectionRanges *  selections);
		static OakSelectionRanges * paste (NSString *& buffer, OakSelectionRanges *  selections, snippet_controller_t& snippets, clipboard_t::entry_ptr entry);
        
		std::vector<NSString *> completions (NSUInteger bow, NSUInteger eow, NSString * prefix, NSString * suffix, NSString * scopeAttributes);
		BOOL setup_completion (NSString * scopeAttributes);
		void next_completion (NSString * scopeAttributes);
		void previous_completion (NSString * scopeAttributes);
        
		// ============
		// = Snippets =
		// ============
        
		void snippet (NSString * str, std::map<NSString *, NSString *>  variables);
		ranges_t snippet (NSUInteger from, NSUInteger to, NSString * str, std::map<NSString *, NSString *>  variables);
        
		void find (NSString * searchFor, NSStringCompareOptions options = , BOOL searchOnlySelection = false);
		ranges_t replace (std::multimap<range_t, NSString *>  replacements, BOOL selectInsertions = false);
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
		BOOL _extend_yank_clipboard = false;
        
		document::OakDocument * _document;
	};
    
	typedef std::shared_ptr<editor_t> editor_ptr;
    
	extern editor_ptr editor_for_document (document::OakDocument * document);
    
