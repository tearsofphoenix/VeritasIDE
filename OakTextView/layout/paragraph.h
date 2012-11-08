#ifndef PARAGRAPH_H_PZ1GB7JU
#define PARAGRAPH_H_PZ1GB7JU


#include <theme/theme.h>


namespace ng
{
	struct line_t;

	struct line_record_t
	{
		line_record_t (NSUInteger line, NSUInteger softline, CGFloat top, CGFloat bottom, CGFloat baseline) : line(line), softline(softline), top(top), bottom(bottom), baseline(baseline) { }

		NSUInteger line;
		NSUInteger softline;
		CGFloat top;
		CGFloat bottom;
		CGFloat baseline;
	};

	struct paragraph_t
	{
		NSUInteger length () const;

		void insert (NSUInteger pos, NSUInteger len, NSString *  buffer, NSUInteger bufferOffset);
		void insert_folded (NSUInteger pos, NSUInteger len, NSString *  buffer, NSUInteger bufferOffset);
		void erase (NSUInteger from, NSUInteger to, NSString *  buffer, NSUInteger bufferOffset);
		void did_update_scopes (NSUInteger from, NSUInteger to, NSString *  buffer, NSUInteger bufferOffset);
		bool layout (OakTheme *  theme, NSString * fontName, CGFloat fontSize, bool softWrap, NSUInteger wrapColumn, ct::metrics_t  metrics, CGRect visibleRect, NSString *  buffer, NSUInteger bufferOffset);

		void draw_background (OakTheme *  theme, NSString * fontName, CGFloat fontSize, ct::metrics_t  metrics, ng::context_t  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef backgroundColor, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor) const;
		void draw_foreground (OakTheme *  theme, NSString * fontName, CGFloat fontSize, ct::metrics_t  metrics, ng::context_t  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef textColor, NSString *  buffer, NSUInteger bufferOffset, OakSelectionRanges *  selection, CGPoint anchor) const;

		ng::index_t index_at_point (CGPoint point, ct::metrics_t  metrics, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor) const;
		CGRect rect_at_index (ng::index_t  index, ct::metrics_t  metrics, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor) const;

		ng::line_record_t line_record_for (NSUInteger line, NSUInteger pos, ct::metrics_t  metrics, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor) const;

		NSUInteger bol (NSUInteger index, NSString *  buffer, NSUInteger bufferOffset) const;
		NSUInteger eol (NSUInteger index, NSString *  buffer, NSUInteger bufferOffset) const;

		NSUInteger index_left_of (NSUInteger index, NSString *  buffer, NSUInteger bufferOffset) const;
		NSUInteger index_right_of (NSUInteger index, NSString *  buffer, NSUInteger bufferOffset) const;

		void set_wrapping (bool softWrap, NSUInteger wrapColumn, ct::metrics_t  metrics);
		void set_tab_size (NSUInteger tabSize, ct::metrics_t  metrics);
		void reset_font_metrics (ct::metrics_t  metrics);

		CGFloat width () const;
		CGFloat height (ct::metrics_t  metrics) const;

		bool structural_integrity () const { return true; }

	private:
		enum node_type_t { kNodeTypeText, kNodeTypeTab, kNodeTypeUnprintable, kNodeTypeFolding, kNodeTypeSoftBreak, kNodeTypeNewline };

		struct node_t
		{
			node_t (node_type_t type, NSUInteger length = 0, CGFloat width = 0) : _type(type), _length(length), _width(width) { }

			void insert (NSUInteger i, NSUInteger len);
			void erase (NSUInteger from, NSUInteger to);
			void did_update_scopes (NSUInteger from, NSUInteger to);

			void layout (CGFloat x, CGFloat tabWidth, OakTheme *  theme, NSString * fontName, CGFloat fontSize, bool softWrap, NSUInteger wrapColumn, ct::metrics_t  metrics, NSString *  buffer, NSUInteger bufferOffset, NSString * fillStr);
			void reset_font_metrics (ct::metrics_t  metrics);
			void draw_background (OakTheme *  theme, NSString * fontName, CGFloat fontSize, ng::context_t  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef backgroundColor, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor, CGFloat lineHeight) const;
			void draw_foreground (OakTheme *  theme, NSString * fontName, CGFloat fontSize, ng::context_t  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef textColor, NSString *  buffer, NSUInteger bufferOffset, std::vector< std::pair<NSUInteger, NSUInteger> >  misspelled, CGPoint anchor, CGFloat baseline) const;

			node_type_t type () const                      { return _type; }
			NSUInteger length () const                         { return _length; }
			std::shared_ptr<ct::line_t> line () const { return _line; }
			CGFloat width () const;
			void update_tab_width (CGFloat x, CGFloat tabWidth, ct::metrics_t  metrics);

		private:
			node_type_t _type;
			NSUInteger _length;
			CGFloat _width;

			std::shared_ptr<ct::line_t> _line;
		};

		std::vector<node_t>::iterator iterator_at (NSUInteger i);

		void insert_text (NSUInteger i, NSUInteger len);
		void insert_tab (NSUInteger i);
		void insert_unprintable (NSUInteger i, NSUInteger len);
		void insert_newline (NSUInteger i, NSUInteger len);

		struct softline_t
		{
			softline_t (NSUInteger offset, CGFloat x, CGFloat y, CGFloat baseline, CGFloat height, NSUInteger first, NSUInteger last) : offset(offset), x(x), y(y), baseline(baseline), height(height), first(first), last(last) { }

			NSUInteger offset;
			CGFloat x;
			CGFloat y;
			CGFloat baseline;
			CGFloat height;
			NSUInteger first;
			NSUInteger last;
		};

		std::vector<softline_t> softlines (ct::metrics_t  metrics, bool softBreaksOnNewline = false) const;

		std::vector<node_t> _nodes;
		bool _dirty = true;
	};

	extern NSString * to_s (paragraph_t  paragraph);

} /* ng */

#endif /* end of include guard: PARAGRAPH_H_PZ1GB7JU */
