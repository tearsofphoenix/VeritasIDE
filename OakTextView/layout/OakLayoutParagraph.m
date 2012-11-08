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
#import "OakSelectionRangeArray.h"
#import "utf8.h"
#import "OakLayoutParagraphSoftLine.h"
#import "OakSelectionIndex.h"
#import <OakFoundation/OakFoundation.h>

@implementation OakLineRecord

+ (id)lineRecordWithLine: (NSUInteger)line
                softLine: (NSUInteger)softLine
                     top: (CGFloat)top
                  bottom: (CGFloat)bottom
                baseline: (CGFloat)baseline
{
    OakLineRecord *record = [[self alloc] init];
    [record setLine: line];
    [record setSoftline: softLine];
    [record setTop: top];
    [record setBottom: bottom];
    [record setBaseline: baseline];
    
    return [record autorelease];
}


@end


@interface OakLayoutParagraph()
{
    node_type_t _type;
    NSUInteger _length;
    CGFloat _width;
    NSMutableArray *_nodes;
    BOOL _dirty;
    
    OakLayoutLine * _line;
}

@end

@implementation OakLayoutParagraph

- (NSUInteger)length
{
    NSUInteger res = 0;
    for (OakLayoutParagraphNode *node in _nodes)
    {
        res += [node length];
    }
    
    return res;
}

- (void)insertContent: (NSString *)buffer
           atPosition: (NSUInteger)pos
               length: (NSUInteger)len
               offset: (NSUInteger)bufferOffset
{
    
    NSMutableArray *newNodes = [NSMutableArray array];
    
    NSString * str = [buffer substringWithRange: NSMakeRange(pos, pos + len)];
    
    NSUInteger from = 0, i = 0;
    
    //    citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
    {
        if(*ch == '\t' || *ch == '\n' || OakStringRepresentationForChar(*ch))
        {
            if(from != i)
            {
                [self insertTextAt: pos - bufferOffset + from
                            length: i - from];
            }
            if(*ch == '\t')
            {
                [self insertTabAt: pos - bufferOffset + i];
            }
            else if(*ch == '\n')
            {
                [self insertNewlineAt: pos - bufferOffset + i
                               length: [ch length]];
                
            }else
            {
                [self insertUnprintableAt: pos - bufferOffset + i
                                   length: [ch length]];
            }
            
            from = i + [ch length];
        }
        
        i += [ch length];
    }
    
    if(from != [str length])
    {
        [self insertTextAt: pos - bufferOffset + from
                    length: [str length] - from];
    }
    
    _dirty = YES;
}

- (void)insertFoldedContent: (NSString *)buffer
                 atPosition: (NSUInteger)pos
                     length: (NSUInteger)len
                     offset: (NSUInteger)bufferOffset
{
    OakLayoutParagraphNode *node = [[OakLayoutParagraphNode alloc] init];
    [node setType: kNodeTypeFolding];
    [node setLength: len];
    
    [_nodes insertObject: node
                 atIndex: pos - bufferOffset];
    //     _nodes.insert(iterator_at(pos - bufferOffset), node_t(kNodeTypeFolding, len));
    _dirty = YES;
    
}

- (void)eraseContent: (NSString *)buffer
                from: (NSUInteger)from
                  to: (NSUInteger)to
              offset: (NSUInteger)bufferOffset
{
    NSUInteger i = bufferOffset;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        NSUInteger len = [node length];
        if(i <= from && from < i + len)
        {
            NSUInteger last = MIN(to - i, len);
            [node eraseFrom: from - i
                         to: last];
            from = i + last;
            if(to - i <= last)
            {
                break;
            }
        }
        i += len;
    }
    
    for(OakLayoutParagraphNode *it in [NSArray arrayWithArray: _nodes])
    {
        if([it length] == 0 && [it type] != kNodeTypeSoftBreak)
        {
            [_nodes removeObject: it];
        }
    }
    
    if(from != to)
    {
        fprintf(stderr, "error erasing %zu-%zu, %zu\n", from, to, bufferOffset);
    }
    
    _dirty = YES;
}

- (void)didUpdateScopesOfContent: (NSString *)buffer
                            from: (NSUInteger)from
                              to: (NSUInteger)to
                          offset: (NSUInteger)bufferOffset
{
    NSUInteger i = bufferOffset;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        [node didUpdateScopesFrom: from - i
                               to: to - i];
        
        i += [node length];
    }
    
    _dirty = YES;
    
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
    if(!_dirty)
    {
        return NO;
    }
    
    NSMutableArray *newNodes = [NSMutableArray arrayWithCapacity: [_nodes count]];
    
    BOOL hasFoldings = NO;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if([node type] != kNodeTypeSoftBreak)
        {
            [newNodes addObject: node];
        }
        
        hasFoldings = (hasFoldings || [node type] == kNodeTypeFolding);
    }
    
    [_nodes setArray: newNodes];
    
    NSUInteger const tabSize = [[buffer indent] tab_size];
    
    NSString * fillStr = nil;
    if(!hasFoldings && softWrap)
    {
        fillStr = @"";
        NSUInteger fillStrWidth = 0;
        
        NSString * str = [buffer substringWithRange: NSMakeRange(bufferOffset, bufferOffset + [self length])];
        
        OakBundleItem * indentedSoftWrapItem;
        OakScopeContext * scope = (buffer scope: (bufferOffset, false).right, buffer.scope(bufferOffset + length(), false).left);
        
        id indentedSoftWrapValue = bundles::value_for_setting("indentedSoftWrap", scope, &indentedSoftWrapItem);
        if(indentedSoftWrapItem)
        {
            NSString * pattern = [indentedSoftWrapValue objectForKeyPath: @"match"];
            NSString *format = [indentedSoftWrapValue objectForKeyPath: @"format"];
            
            if(pattern && format)
            {
                if(regexp::match_t  m = regexp::search(pattern, str.data(), str.data() + str.size()))
                {
                    NSString * tmp = format_string::expand(format, m.captures());
                    citerate(ch, diacritics::make_range(tmp.data(), tmp.data() + tmp.size()))
                    {
                        if(*ch == '\t')
                        {
                            fillStr.append(NSString *(tabSize - (fillStrWidth % tabSize), ' '));
                            
                        }else
                        {
                            fillStr.append(&ch, ch.length());
                        }
                        
                        fillStrWidth += (*ch == '\t' ? tabSize - (fillStrWidth % tabSize) : 1);
                    }
                }
            }
            
            if(wrapColumn < fillStrWidth)
            {
                fillStr = "    ";
                fillStrWidth = 4;
            }
        }
        
        citerate(offset, text::soft_breaks(str, wrapColumn, tabSize, fillStrWidth))
        {
            _nodes.insert(iterator_at(*offset), node_t(kNodeTypeSoftBreak, 0, fillStrWidth * metrics.column_width()));
        }
    }
    
    CGFloat x = 0;
    NSUInteger i = bufferOffset;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        [node layoutX: x
             tabWidth: tabSize * [metrics columnWidth]
                theme: theme
             fontName: fontName
             fontSize: fontSize
             softWrap: softWrap
           wrapColumn: wrapColumn
              metrics: metrics
              content: buffer
               offset: i
           fillString: fillStr];
        
        x += [node width];
        i += [node length];
    }
    
    _dirty = NO;
    
    return YES;
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
    NSArray *lines = [self softLinesWithMetrics: metrics
                                 breakOnNewLine: NO];
    
    for(OakLayoutParagraphSoftLine *line in lines)
    {
        CGFloat x = line.x;
        NSUInteger offset = line.offset;
        
        for(NSUInteger jLooper = line.first; jLooper < line.last; ++jLooper)
        {
            OakLayoutParagraphNode *node = [_nodes objectAtIndex: jLooper];
            [node drawBackgroundWithThem: theme
                                fontName: fontName
                                fontSize: fontSize
                                 context: context
                               isFlipped: isFlipped
                             visibleRect: visibleRect
                          showInvisibles: showInvisibles
                         backgroundColor: backgroundColor
                                 content: buffer
                                  offset: bufferOffset
                                  anchor: CGPointMake(anchor.x + x, anchor.y + line.y)
                              lineHeight: [line height]];
            
            x += [node width];
            offset += [node length];
        }
    }
}

- (void)drawForegroundWithTheme: (OakTheme *) theme
                       fontName: (NSString * )fontName
                       fontSize: (CGFloat) fontSize
                        metrics: (OakLayoutMetrics *)metrics
                        context: (OakLayoutContext *) context
                      isFlipped: (BOOL)isFlipped
                    visibleRect: (CGRect)visibleRect
                 showInvisibles: (BOOL)showInvisibles
                      textColor: (NSColor *)textColor
                        content: (NSString *) buffer
                         offset: (NSUInteger) bufferOffset
                      selection: (OakSelectionRangeArray *)selection
                         anchor: (CGPoint) anchor
{
    CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, 1, 0, 0));
    
    NSArray *lines = [self softLinesWithMetrics: metrics
                                 breakOnNewLine: NO];
    
    for(OakLayoutParagraphSoftLine *line in lines)
    {
        CGFloat x = line.x;
        NSUInteger offset = bufferOffset + line.offset;
        
        for(NSUInteger jLooper = line.first; jLooper < line.last; ++jLooper)
        {
            OakLayoutParagraphNode *node = [_nodes objectAtIndex: jLooper];
            
            NSMutableArray *misspelled = [NSMutableArray array];
            
            if([node type] == kNodeTypeText)
            {
                auto misspellings = buffer.misspellings(offset, offset + node->length());
                for(auto it = misspellings.begin(); it != misspellings.end(); )
                {
                    BOOL flag = it->second;
                    NSUInteger from = it->first;
                    NSUInteger to = ++it != misspellings.end() ? it->first : node->length();
                    if(flag)
                    {
                        BOOL intersects = NO;
                        iterate(range, selection)
                        {
                            intersects = intersects || !(to + offset < range->min().index || range->max().index < from + offset);
                        }
                        
                        if(!intersects)
                        {
                            [misspelled addObject: [NSValue valueWithRange: NSMakeRange(from, to)]];
                        }
                    }
                }
            }
            
            [node drawForegroundWithTheme: theme
                                 fontName: fontName
                                 fontSize: fontSize
                                  context: context
                                isFlipped: isFlipped
                              visibleRect: visibleRect
                           showInvisibles: showInvisibles
                                textColor: textColor
                                  content: buffer
                                   offset: offset
                               misspelled: misspelled
                                   anchor: CGPointMake(anchor.x + x, anchor.y + line.y)
                                 baseline: line.baseline];
            x += [node width];
            offset += [node length];
        }
    }
    
}

- (OakSelectionIndex *)indexAtPoint: (CGPoint)point
                            metrics: (OakLayoutMetrics *)metrics
                            content: (NSString *)buffer
                             offset: (NSUInteger)bufferOffset
                             anchor: (CGPoint)anchor
{
    NSArray *lines =  [self softLinesWithMetrics: metrics
                                  breakOnNewLine: NO];
    
    [lines enumerateObjectsUsingBlock: (^(OakLayoutParagraphSoftLine *obj, NSUInteger idx, BOOL *stop)
                                        {
                                            if(anchor.y + obj.y <= point.y && point.y < anchor.y + obj.y + obj.height)
                                            {
                                                CGFloat x = obj.x;
                                                NSUInteger offset = obj.offset;
                                                
                                                for(NSUInteger jLooper = obj.first; jLooper < obj.last; ++jLooper)
                                                {
                                                    if([node type] == kNodeTypeSoftBreak)
                                                    {
                                                        NSUInteger res = bufferOffset + offset;
                                                        if(i+1 != [lines count] && res == bufferOffset + lines[idx + 1].offset)
                                                        {
                                                            res -= buffer[res-1].size();
                                                        }
                                                        return res;
                                                    }
                                                    else if([node type] == kNodeTypeNewline)
                                                    {
                                                        NSUInteger carry = point.x > anchor.x + x ? (NSUInteger)floor((point.x - (anchor.x + x)) / [metrics columnWidth]) : 0;
                                                        OakSelectionIndex *indx = [OakSelectionIndex al](bufferOffset + offset, carry);
                                                    }
                                                    
                                                    if(point.x <= anchor.x + x)
                                                    {
                                                        return bufferOffset + offset;
                                                    }
                                                    else if(anchor.x + x < point.x && point.x < anchor.x + x + node->width())
                                                    {
                                                        CGFloat delta = point.x - (anchor.x + x);
                                                        if([node type] == kNodeTypeText && [node line])
                                                        {
                                                            NSUInteger res = bufferOffset + offset + [[node line] indexForOffset: delta];
                                                            if(i+1 != lines.size() && res == bufferOffset + lines[i+1].offset)
                                                                res -= buffer[res-1].size();
                                                            return res;
                                                        }
                                                        return bufferOffset + offset + lround(delta / node->width()) * node->length();
                                                    }
                                                    
                                                    x += [node width];
                                                    offset += [node length];
                                                }
                                            }
                                        })];
    
    return bufferOffset + [self length];
}

- (CGRect)rectAtIndex: (OakSelectionIndex *)index
              metrics: (OakLayoutMetrics *)metrics
               buffer: (NSString *)buffer
               offset: (NSUInteger)bufferOffset
               anchor: (CGPoint)anchor
{
    NSUInteger needle = index.index - bufferOffset;
    CGFloat caretOffset = [index carry] * [metrics columnWidth];
    
    NSArray *lines = [self softLinesWithMetrics: metrics
                                 breakOnNewLine: NO];
    
    for(NSUInteger i = 0; i < [lines size]; ++i)
    {
        OakLayoutParagraphSoftLine *line = [lines objectAtIndex: i];
        
        if([line offset] <= needle && (i+1 == [lines size] || needle < [line offset]))
        {
            CGFloat x = [line x]
            CGFloat y = [line y];
            
            NSUInteger offset = [line offset];
            
            for(NSUInteger jLooper =  [line first],  jLooper < [line last]; ++jLooper)
            {
                if(offset <= needle && needle < offset + [node length])
                {
                    if([node type] == kNodeTypeText && [node line])
                    {
                        return CGRectMake(anchor.x + x + [[node line] offsetForIndex: needle - offset] + caretOffset,
                                          anchor.y + y,
                                          [metrics columnWidth],
                                          [line height]);
                    }
                    
                    return CGRectMake(anchor.x + x + (needle - offset) * [node width] / [node length] + caretOffset,
                                      anchor.y + y,
                                      1,
                                      [line height]);
                }
                
                x += [node width];
                offset += [node length];
            }
            
            return CGRectMake(anchor.x + x + caretOffset,
                              anchor.y + y,
                              1,
                              [line height]);
        }
    }
    
    return CGRectMake(anchor.x + caretOffset,
                      anchor.y,
                      1,
                      [[line lastObject] height]);
}

- (OakLineRecord *)lineRecordFor: (NSUInteger)line
                        position: (NSUInteger)pos
                         metrics: (OakLayoutMetrics *)metrics
                          buffer: (NSString *)buffer
                          offset: (NSUInteger)bufferOffset
                          anchor: (CGPoint)anchor
{
    NSUInteger needle = pos - bufferOffset;
    
    NSArray *lines = [self softLinesWithMetrics: metrics
                                 breakOnNewLine: NO];
    
    CGFloat y = anchor.y;
    for(NSUInteger i = 0; i < [lines count]; ++i)
    {
        OakLayoutParagraphSoftLine *line = [lines objectAtIndex: i];
        
        if([line offset] <= needle && (i + 1 == [lines count]
                                       || needle < [[lines objectAtIndex: i + 1] offset]))
        {
            return OakLineRecord *(line, [line offset], y, y + [line height], [line baseline]);
        }
        
        y += [line height];
    }
    
    return OakLineRecord *(line, 0, 0, 0, 0);
}

- (NSUInteger)beginOfLine: (NSUInteger)index
                  content: (NSString *)buffer
                   offset: (NSUInteger)bufferOffset
{
    NSUInteger i = bufferOffset;
    NSUInteger bol = i;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if(index < i)
        {
            break;
        }
        
        i += [node length];
        
        if(node->type() == kNodeTypeSoftBreak)
        {
            bol = i;
        }
    }
    
    return bol;
    
}

- (NSUInteger)endOfLine: (NSUInteger)index
                content: (NSString *)buffer
                 offset: (NSUInteger)bufferOffset
{
    NSUInteger i = bufferOffset;
    
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if(index < i && [node type] == kNodeTypeSoftBreak)
        {
            return i - buffer[i-1].size();
        }
        
        if(index <= i && [node type] == kNodeTypeNewline)
        {
            return i;
        }
        
        i += [node length];
    }
    
    return i;
}

- (NSUInteger)indexLeftOf: (NSUInteger)index
                  content: (NSString *)buffer
                   offset: (NSUInteger)bufferOffset
{
    if(index != bufferOffset)
    {
        index -= buffer[index-1].size();;
    }
    
    NSUInteger i = bufferOffset;
    
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if(i < index && index < i + [node length] && [node type] == kNodeTypeFolding)
        {
            return i;
        }
        
        i += [node length];
    }
    
    return index;
    
}

- (NSUInteger)indexRightOf: (NSUInteger)index
                   content: (NSString *)buffer
                    offset: (NSUInteger)bufferOffset
{
    if(index != bufferOffset + length())
    {
        index += buffer[index].size();
    }
    
    NSUInteger i = bufferOffset;
    
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if(i < index && index < i + [node length] && [node type] == kNodeTypeFolding)
        {
            return i + [node length];
        }
        
        i += [node length];
    }
    
    return index;
}

- (void)setWrapping: (BOOL)softWrap
         wrapColumn: (NSUInteger)wrapColumn
            metrics: (OakLayoutMetrics *)metrics
{
    
    _dirty = YES;
}

- (void)setTabSize: (NSUInteger)tabSize
           metrics: (OakLayoutMetrics *)metrics
{
    double const tabWidth = tabSize * [metrics columnWidth];
    
    NSArray *lines = [self softLinesWithMetrics: metrics
                                 breakOnNewLine: NO];
    
    for(NSUInteger i = 0; i < [lines count]; ++i)
    {
        OakLayoutParagraphSoftLine *line = [lines objectAtIndex: i];
        
        CGFloat x = [line x];
        
        for (NSUInteger j = [line first]; j < [line last]; ++j)
        {
            OakLayoutParagraphNode *node = [_nodes objectAtIndex: j];
            
            if([node type] == kNodeTypeTab)
            {
                [node updateTabWidth: x
                            tabWidth: tabWidth
                             metrics: metrics];
            }
            
            x += [node width];
        }
    }
    
}

- (void)resetFontWithMetrics: (OakLayoutMetrics *)metrics
{
    _dirty = YES;
    
    [_nodes makeObjectsPerformSelector: @selector(resetFontMetrics:)
                            withObject: metrics];
}

- (CGFloat)width
{
    CGFloat x = 0, res = 0;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if([node type] == kNodeTypeSoftBreak)
        {
            x = 0;
        }
        
        x += [node width];
        
        res = MAX(x, res);
    }
    
    return res;
}

- (CGFloat)heightWithMetrics: (OakLayoutMetrics *)metrics
{
    OakLayoutParagraphSoftLine * line = [[self softLinesWithMetrics: metrics] lastObject];
    return [lines y] + [lines height];
}

- (BOOL)structuralIntegrity
{
    return YES;
}


- (OakLayoutParagraphNode *)nodeAt: (NSUInteger) i
{
    NSUInteger from = 0;
    
    [_nodes enumerateObjectsUsingBlock: (^(OakLayoutParagraphNode *node, NSUInteger idx, BOOL *stop)
                                         {
                                             
                                             if(from == i)
                                             {
                                                 return node;
                                                 
                                             }else if(from < i && i < from + [node length])
                                             {
                                                 NSUInteger len = [node length] - (i - from);
                                                 [node eraseFrom: 1- from
                                                              to: [node length]];
                                                 
                                                 OakLayoutParagraphNode *newNode = [[OakLayoutParagraphNode alloc] init];
                                                 [newNode setType: kNodeTypeText];
                                                 [newNode setLength: len];
                                                 
                                                 [_nodes insertObject: newNode
                                                              atIndex: idx + 1];
                                                 
                                                 return newNode;
                                             }
                                             
                                             from += [node length];
                                         })];
    
    return nil;
}

- (void)insertTextAt: (NSUInteger) i
              length: (NSUInteger)len
{
    NSUInteger from = 0;
    for(OakLayoutParagraphNode *node in _nodes)
    {
        if(from <= i && i <= from + [node ength] && [node type] == kNodeTypeText)
        {
            [node insert: i - from
                  length: len];
        }
        from += [node length];
    }
    
    _nodes.insert(iterator_at(i), [OakLayoutParagraphNode nodeWithType: kNodeTypeText
                                                                length: len]);
    
}

- (void)insertTabAt: (NSUInteger) i
{
    OakLayoutParagraphNode *node = [OakLayoutParagraphNode nodeWithType: kNodeTypeTab
                                                                 length: 1];
    [node setWidth: 10];
    _nodes.insert(iterator_at(i), node);
    
}

- (void)insertUnprintableAt: (NSUInteger) i
                     length: (NSUInteger)len
{
    _nodes.insert(iterator_at(i), [OakLayoutParagraphNode nodeWithType: kNodeTypeUnprintable
                                                                length: len]);
    
}

- (void)insertNewlineAt: (NSUInteger)i
                 length: (NSUInteger)len
{
    _nodes.insert(iterator_at(i), [OakLayoutParagraphNode nodeWithType: kNodeTypeNewline
                                                                length: len]);
    
}

- (NSArray *)softLinesWithMetrics: (OakLayoutMetrics *)metrics
                   breakOnNewLine: (BOOL)softBreaksOnNewline
{
    NSMutableArray *softlines = [NSMutableArray array];
    
    CGFloat x = 0, y = 0;
    NSUInteger first = 0, firstOffset = 0, offset = 0;
    CGFloat ascent = 0, descent = 0, leading = 0;
    [_nodes enumerateObjectsUsingBlock: (^(OakLayoutParagraphNode *node, NSUInteger idx, BOOL *stop)
                                         {
                                             if([node type] == kNodeTypeSoftBreak)
                                             {
                                                 OakLayoutParagraphSoftLine *softline = [OakLayoutParagraphSoftLine lineWithOffset: firstOffset
                                                                                                                                 x: x
                                                                                                                                 y: y
                                                                                                                          baseline: [metrics baseline: ascent]
                                                                                                                            height: [metrics lineHeightWithMinAscent: ascent
                                                                                                                                                          minDescent: descent
                                                                                                                                                          minLeading: leading]
                                                                                                                             first: first
                                                                                                                              last: i + (softBreaksOnNewline ? 0 : 1)];
                                                 [softlines addObject: softline];
                                                 
                                                 firstOffset = offset;
                                                 x = (softBreaksOnNewline ? 0 : [node width]);
                                                 
                                                 y += [metrics lineHeightWithMinAscent: ascent
                                                                            minDescent: descent
                                                                            minLeading: leading];
                                                 
                                                 first = i + (softBreaksOnNewline ? 0 : 1);
                                                 ascent = 0;
                                                 descent = 0;
                                                 leading = 0;
                                             }
                                             
                                             if([node line])
                                             {
                                                 CGFloat a, d, l;
                                                 [[node line] getWidthAscent: &a
                                                                     descent: &d
                                                                     leading: &l];
                                                 
                                                 ascent  = MAX(ascent,  a);
                                                 descent = MAX(descent, d);
                                                 leading = MAX(leading, l);
                                             }
                                             
                                             offset += [node length];
                                         })];
    
    
    [softlines addObject: [OakLayoutParagraphSoftLine lineWithOffset: firstOffset
                                                                   x: x
                                                                   y: y
                                                            baseline: [metrics baseline: ascent]
                                                              height: [metrics lineHeightWithMinAscent: ascent
                                                                                            minDescent: descent
                                                                                            minLeading: leading]
                                                               first: first
                                                                last: [_nodes count]
                           ]
     ];
    
    return softlines;
}

@end

