//
//  OakLayoutParagraph.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakLayoutParagraph.h"
#import "OakLayoutLine.h"
#import "OakLayoutMetrics.h"

@interface OakLayoutParagraph()
{
    node_type_t _type;
    NSUInteger _length;
    CGFloat _width;
    
    OakLayoutLine * _line;
}
@end

@implementation OakLayoutParagraph

- (NSUInteger)length
{
    return _length;
}

- (void)insertContent: (NSString *)buffer
           atPosition: (NSUInteger)pos
               length: (NSUInteger)len
               offset: (NSUInteger)offset
{
    
}

- (void)insertFoldedContent: (NSString *)buffer
                 atPosition: (NSUInteger)pos
                     length: (NSUInteger)len
                     offset: (NSUInteger)offset
{
    
}

- (void)eraseContent: (NSString *)buffer
                from: (NSUInteger)from
                  to: (NSUInteger)to
              offset: (NSUInteger)offset
{
    
}

- (void)didUpdateScopesOfContent: (NSString *)buffer
                            from: (NSUInteger)from
                              to: (NSUInteger)to
                          offset: (NSUInteger)offset
{
    
}

- (BOOL)layoutWithTheme: (OakTheme *)theme
               fontName: (NSString *)fontName
               fontSize: (CGFloat)fontSize
               softWrap: (BOOL)softWrap
             wrapColumn: (NSUInteger)wrapColumn
                metrics: (OakLayoutMetrics *)metrics
            visibleRect: (CGRect)visibleRect
                content: (NSString * ) buffer
                 offset: (NSUInteger)bufferOffset
{
    
}


- (void)drawBackgroundWithTheme: (OakTheme *) theme
                       fontName: (NSString * )fontName
                       fontSize: (CGFloat) fontSize
                        metrics: (OakLayoutMetrics *)metrics
                        context: (OakLayoutContext *) context
                      isFlipped: (BOOL)isFlipped
                    visibleRect: (CGRect)visibleRect
                 showInvisibles: (BOOL)showInvisibles
                backgroundColor: (NSColor *)backgroundColor
                        content: (NSString *) buffer
                         offset: (NSUInteger) bufferOffset
                         anchor: (CGPoint) anchor
{
    
}

void draw_foreground (OakTheme *  theme, NSString * fontName, CGFloat fontSize, ct::metrics_t  metrics, OakLayoutContext *  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef textColor, NSString *  buffer, NSUInteger bufferOffset, OakSelectionRanges *  selection, CGPoint anchor) const;

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

struct node_t
{
    node_t (node_type_t type, NSUInteger length = 0, CGFloat width = 0) : _type(type), _length(length), _width(width) { }
    
    void insert (NSUInteger i, NSUInteger len);
    void erase (NSUInteger from, NSUInteger to);
    void did_update_scopes (NSUInteger from, NSUInteger to);
    
    void layout (CGFloat x, CGFloat tabWidth, OakTheme *  theme, NSString * fontName, CGFloat fontSize, bool softWrap, NSUInteger wrapColumn, ct::metrics_t  metrics, NSString *  buffer, NSUInteger bufferOffset, NSString * fillStr);
    void reset_font_metrics (ct::metrics_t  metrics);
    void draw_background (OakTheme *  theme, NSString * fontName, CGFloat fontSize, OakLayoutContext *  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef backgroundColor, NSString *  buffer, NSUInteger bufferOffset, CGPoint anchor, CGFloat lineHeight) const;
    void draw_foreground (OakTheme *  theme, NSString * fontName, CGFloat fontSize, OakLayoutContext *  context, bool isFlipped, CGRect visibleRect, bool showInvisibles, CGColorRef textColor, NSString *  buffer, NSUInteger bufferOffset, std::vector< std::pair<NSUInteger, NSUInteger> >  misspelled, CGPoint anchor, CGFloat baseline) const;
    
    node_type_t type () const                      { return _type; }
    NSUInteger length () const                         { return _length; }
    std::shared_ptr<OakLayoutLine *> line () const { return _line; }
    CGFloat width () const;
    void update_tab_width (CGFloat x, CGFloat tabWidth, ct::metrics_t  metrics);
    
private:
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

@end
