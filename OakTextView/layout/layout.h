#ifndef LAYOUT_H_VWUBRBQ1
#define LAYOUT_H_VWUBRBQ1

#include "paragraph.h"

#include <selection/selection.h>




namespace ct
{
    struct metrics_t;
    struct line_t;
};

enum kRectsIncludeMode
{
    kRectsIncludeAll,
    kRectsIncludeCarets,
    kRectsIncludeSelections
};

namespace ng
{
	struct folds_t;

	struct layout_t : NSObject<OakLayoutMovement>
	{
		struct margin_t
		{
			margin_t (NSUInteger m) : left(m), top(m), right(m), bottom(m) { }
			NSUInteger left, top, right, bottom;
		};

		layout_t (NSString *& buffer, OakTheme *  theme, NSString * fontName = "Menlo", CGFloat fontSize = 12, bool softWrap = false, NSUInteger wrapColumn = 0, NSString * folded = NULL_STR, margin_t  margin = margin_t(8));
		~layout_t ();

		// _buffer_callback is managed with new/delete so can’t be copied
		layout_t (layout_t  rhs) = delete;
		layout_t& operator= (layout_t  rhs) = delete;

		// ============
		// = Settings =
		// ============

		void set_theme (OakTheme *  theme);
		void set_font (NSString * fontName, CGFloat fontSize);
		void set_margin (margin_t  margin);
		void set_wrapping (bool softWrap, NSUInteger wrapColumn);

		OakTheme *  theme () const         { return _theme; }
		NSString * font_name () const   { return _font_name; }
		CGFloat font_size () const              { return _font_size; }
		NSUInteger tab_size () const                { return _tab_size; }
		margin_t  margin () const         { return _margin; }
		bool wrapping () const                  { return _wrapping; }
		NSUInteger effective_wrap_column () ;

		// ======================
		// = Display Attributes =
		// ======================

		void set_is_key (bool isKey);
		void set_draw_caret (bool drawCaret);
		void set_draw_wrap_column (bool drawWrapColumn);
		void set_drop_marker (OakSelectionIndex * dropMarkerIndex);
		void set_viewport_size (CGSize size);

		bool draw_wrap_column () const          { return _draw_wrap_column; }

		// ======================

		void draw (OakLayoutContext *  context, CGRect rectangle, bool isFlipped, bool showInvisibles, OakSelectionRanges *  selection, OakSelectionRanges *  highlightRanges = OakSelectionRanges *(), bool drawBackground = true, CGColorRef textColor = NULL);
		OakSelectionIndex * index_at_point (CGPoint point) ;
		CGRect rect_at_index (OakSelectionIndex *  index) ;
		CGRect rect_for_range (NSUInteger first, NSUInteger last) ;
		std::vector<CGRect> rects_for_ranges (OakSelectionRanges *  ranges, kRectsIncludeMode mode = kRectsIncludeAll) ;

		CGFloat width () ;
		CGFloat height () ;

		void begin_refresh_cycle (OakSelectionRanges *  selection, OakSelectionRanges *  highlightRanges = OakSelectionRanges *());
		std::vector<CGRect> end_refresh_cycle (OakSelectionRanges *  selection, CGRect visibleRect, OakSelectionRanges *  highlightRanges = OakSelectionRanges *());
		void did_update_scopes (NSUInteger from, NSUInteger to);

		OakSelectionIndex * index_above (OakSelectionIndex *  index) ;
		OakSelectionIndex * index_right_of (OakSelectionIndex *  index) ;
		OakSelectionIndex * index_below (OakSelectionIndex *  index) ;
		OakSelectionIndex * index_left_of (OakSelectionIndex *  index) ;
		OakSelectionIndex * index_at_bol_for (OakSelectionIndex *  index) ;
		OakSelectionIndex * index_at_eol_for (OakSelectionIndex *  index) ;
		OakSelectionIndex * page_up_for (index_t  index) ;
		OakSelectionIndex * page_down_for (index_t  index) ;

		// ===================
		// = Folding Support =
		// ===================

		bool is_line_folded (NSUInteger n) ;
		bool is_line_fold_start_marker (NSUInteger n) ;
		bool is_line_fold_stop_marker (NSUInteger n) ;
		void fold (NSUInteger from, NSUInteger to);
		void remove_enclosing_folds (NSUInteger from, NSUInteger to);
		void toggle_fold_at_line (NSUInteger n, bool recursive);
		void toggle_all_folds_at_level (NSUInteger level);
		NSString * folded_as_string () ;

		// =======================
		// = Gutter view support =
		// =======================

		line_record_t line_record_for (CGFloat y) ;
		line_record_t line_record_for (text::pos_t  pos) ;

		// =================
		// = Debug support =
		// =================

		bool structural_integrity () ;
		NSString * to_s () ;

	private:
		struct row_key_t
		{
			row_key_t (NSUInteger length = 0, CGFloat height = 0, CGFloat width = 0) : _length(length), _height(height), _width(width) { }

			bool operator==     (row_key_t  rhs) const { return _length == rhs._length && _height == rhs._height && _width == rhs._width; }
			row_key_t operator+ (row_key_t  rhs) const { return row_key_t(_length + rhs._length, _height + rhs._height, MAX(_width, rhs._width)); }
			row_key_t operator- (row_key_t  rhs) const { return row_key_t(_length - rhs._length, _height - rhs._height, MIN(_width, rhs._width)); }

			NSUInteger _length;
			CGFloat _height;
			CGFloat _width;
		};

		typedef oak::basic_tree_t<row_key_t, paragraph_t> row_tree_t;

		CGFloat content_width () const         { return ceil(MAX(_rows.aggregated()._width, _viewport_size.width - _margin.left - _margin.right)); }
		CGFloat content_height () const        { return ceil(MAX(_rows.aggregated()._height, _viewport_size.height - _margin.top - _margin.bottom)); }

		row_tree_t::iterator row_for_offset (NSUInteger i) ;
		CGFloat default_line_height (CGFloat minAscent = 0, CGFloat minDescent = 0, CGFloat minLeading = 0) ;
		CGRect rect_for (row_tree_t::iterator rowIter) ;
		CGRect full_width (CGRect  rect) ;
		CGRect full_height (CGRect  rect) ;
		bool effective_soft_wrap (row_tree_t::iterator rowIter) ;

		void set_tab_size (NSUInteger tabSize);
		void did_insert (NSUInteger first, NSUInteger last);
		void did_erase (NSUInteger from, NSUInteger to);

		void setup_font_metrics ();
		void clear_text_widths ();

		void update_metrics (CGRect visibleRect);
		bool update_row (row_tree_t::iterator rowIter);

		void refresh_line_at_index (NSUInteger index, bool fullRefresh);
		void did_fold (NSUInteger from, NSUInteger to);

		static int row_y_comp (CGFloat y, row_key_t  offset, row_key_t  node)       { return y < offset._height ? -1 : (y == offset._height ? 0 : +1); }
		static int row_offset_comp (NSUInteger i, row_key_t  offset, row_key_t  node)   { return i < offset._length ? -1 : (i == offset._length ? 0 : +1); }

		static NSString * row_to_s (row_tree_t::value_type  info);

		mutable row_tree_t _rows;
		std::shared_ptr<folds_t> _folds;

		NSString *&      _buffer;
		ng::callback_t*    _buffer_callback;

		OakTheme *          _theme;
		NSString *        _font_name;
		CGFloat            _font_size;
		NSUInteger             _tab_size;
		bool               _wrapping;
		bool               _draw_wrap_column = false;
		NSUInteger             _wrap_column;
		margin_t           _margin;
		CGSize             _viewport_size = CGSizeZero;

		bool               _is_key = false;
		bool               _draw_caret = false;
		OakSelectionIndex *        _drop_marker;

		std::shared_ptr<OakLayoutMetrics *> _metrics;

		NSUInteger _pre_refresh_revision;
		NSUInteger _pre_refresh_caret;
		std::vector<CGRect> _pre_refresh_carets;
		std::vector<CGRect> _pre_refresh_selections;
		std::vector<CGRect> _pre_refresh_highlight_border;
		std::vector<CGRect> _pre_refresh_highlight_interior;
		std::vector<CGRect> _dirty_rects;
		NSUInteger _refresh_counter = 0;
	};

} /* ng */

#endif /* end of include guard: LAYOUT_H_VWUBRBQ1 */
