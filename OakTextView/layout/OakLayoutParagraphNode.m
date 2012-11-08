//
//  OakLayoutParagraphNode.m
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakLayoutParagraphNode.h"
#import "OakLayoutContext.h"
#import "OakLayoutMetrics.h"
#import "theme.h"
#import "OakLayoutLine.h"
#import "OakFunctions.h"
#import "utf8.h"

static BOOL s_OakLayoutParagraphIsSpaceCharacter(NSInteger ch)
{
    static NSInteger SpaceCharacters[] =
    {
        0x200B, // ZERO WIDTH SPACE
        0x200C, // ZERO WIDTH NON-JOINER
        0x200D, // ZERO WIDTH JOINER
        0x2028, // LINE SEPARATOR
        0x2029, // PARAGRAPH SEPARATOR
        0x2060, // WORD JOINER
        0xFEFF  // ZERO WIDTH NO-BREAK SPACE
    };
    
    for (NSUInteger iLooper = 0; iLooper < sizeof(SpaceCharacters) / sizeof(SpaceCharacters[0]); ++iLooper)
    {
        if (ch == SpaceCharacters[iLooper])
        {
            return YES;
        }
    }
    
    return NO;
}


NSString * OakStringRepresentationForChar (uint32_t ch)
{
    
    
    if((0x20 <= ch && ch <= 0x7E) || ch == '\t' || ch == '\n')
    {
        return nil;
    }
    
    switch(ch)
    {
        case '\f': return @"<NP>";
        case '\r': return @"<CR>";
        case '\b': return @"<BS>";
        case 0x00: return @"<NUL>";
        case 0x1B: return @"<ESC>";
        case 0x1C: return @"<FS>";
        case 0x1D: return @"<GS>";
        case 0x1E: return @"<RS>";
        case 0x1F: return @"<US>";
        case 0xA0: return @"·";
            
        default:
        {
            if(0x00 < ch && ch <= 'Z'-'A'+1)
            {
                return [NSString stringWithFormat: @"^%c", ch - 1 + 'A'];
            }
            else if(ch < 0x20 || (0x7E < ch && ch < 0xA0))
            {
                return @"◆";
            }
            else if((0xE000 <= ch && ch <= 0xF8FF && ch != OakUTF8StringToChar(@""))
                    || s_OakLayoutParagraphIsSpaceCharacter(ch) )
            {
                return [NSString stringWithFormat: @"<U+%04X>", ch];
            }
            else if((0x0F0000 <= ch && ch <= 0x0FFFFD) || (0x100000 <= ch && ch <= 0x10FFFD))
            {
                return [NSString stringWithFormat: @"<U+%06X>", ch];
            }
        }
            break;
    }
    
    return nil;
}


static double const kFoldingDotsRatio = 16.0 / 10.0; // FIXME Folding dots ratio should be obtained from the image and given to layout_t

@implementation OakLayoutParagraphNode

+ (id)nodeWithType: (node_type_t)type
            length: (NSUInteger)length
{
    OakLayoutParagraphNode *node = [[OakLayoutParagraphNode alloc] init];
    [node setType: type];
    [node setLength: length];
    
    return [node autorelease];
}

- (void)insert: (NSUInteger)i
        length: (NSUInteger)len
{
    _length += len;
    _line = nil;
    
}

- (void)eraseFrom: (NSUInteger)from
               to: (NSUInteger)to
{
    _length -= to - from;
    _line = nil;
}

- (void)didUpdateScopesFrom: (NSUInteger)from
                         to: (NSUInteger)to
{
    _line = nil;
}

- (void)layoutX: (CGFloat)x
       tabWidth: (CGFloat)tabWidth
          theme: (OakTheme *)theme
       fontName: (NSString *)fontName
       fontSize: (CGFloat)fontSize
       softWrap: (BOOL)softWrap
     wrapColumn: (NSUInteger)wrapColumn
        metrics: (OakLayoutMetrics *)metrics
        content: (NSString *)buffer
         offset: (NSUInteger)bufferOffset
     fillString: (NSString *)fillStr
{
    if(_line)
    {
        return;
    }
    
    NSRange range = NSMakeRange(bufferOffset, bufferOffset + _length);
    
    switch(_type)
    {
        case kNodeTypeText:
        {
            _line = [[OakLayoutLine alloc] initWithText: [buffer substringWithRange: range]
                                                 scopes: [buffer scopes: range]
                                                  theme: theme
                                               fontName: fontName
                                               fontSize: fontSize
                                              textColor: nil];
        }
            break;
            
        case kNodeTypeUnprintable:
        {
            NSString * str = OakStringRepresentationForChar(OakUTF8StringToChar([buffer substringWithRange: range]));
            NSMutableDictionary *scopes = [NSMutableDictionary dictionary];
            
            [scopes setObject: [buffer scope: bufferOffset].right.append("deco.unprintable")
                       forKey: @0];
            
            _line = [[OakLayoutLine alloc] initWithText: str
                                                 scopes: scopes
                                                  theme: theme
                                               fontName: fontName
                                               fontSize: fontSize
                                              textColor: nil];
        }
            break;
            
        case kNodeTypeTab:
        {
            [self updateTabWidth: x
                        tabWidth: tabWidth
                         metrics: metrics];
        }
            break;
            
        case kNodeTypeFolding:
        {
            _width = round([metrics capHeight] * kFoldingDotsRatio);
        }
            break;
            
        case kNodeTypeSoftBreak:
        {
            NSMutableDictionary *scopes = [NSMutableDictionary dictionary];
            
            [scopes setObject: buffer.scope(bufferOffset).right.append("deco.indented-wrap")
                       forKey: @0];
            _line = [[OakLayoutLine alloc] initWithText: fillStr
                                                 scopes: scopes
                                                  theme: theme
                                               fontName: fontName
                                               fontSize: fontSize
                                              textColor: nil];
        }
            break;
    }
}

- (void)resetFontMetrics: (OakLayoutMetrics *)metrics
{
    _line = nil;
}

- (void)drawBackgroundWithThem: (OakTheme *)theme
                      fontName: (NSString *)fontName
                      fontSize: (CGFloat)fontSize
                       context: (OakLayoutContext *)context
                     isFlipped: (BOOL)isFlipped
                   visibleRect: (CGRect)visibleRect
                showInvisibles: (BOOL)showInvisibles
               backgroundColor: (NSColor *)backgroundColor
                       content: (NSString *)buffer
                        offset: (NSUInteger)bufferOffset
                        anchor: (CGPoint)anchor
                    lineHeight: (CGFloat)lineHeight
{
    if(_line)
    {
        [_line drawBackgroundAtPoint: anchor
                              height: lineHeight
                             context: context
                             flipped: isFlipped
                     backgroundColor: backgroundColor];
    }
    
    if(_type != kNodeTypeText)
    {
        id scope = nil;
        _type == kNodeTypeSoftBreak ? [buffer scope: bufferOffset].left : [buffer scope: bufferOffset].right;
        switch(_type)
        {
            case kNodeTypeUnprintable: scope = scope.append("deco.unprintable");   break;
            case kNodeTypeFolding:     scope = scope.append("deco.folding");       break;
            case kNodeTypeSoftBreak:   scope = scope.append("deco.indented-wrap"); break;
        }
        
        styles_t const styles = theme->styles_for_scope(scope, fontName, fontSize);
        if(!CFEqual(backgroundColor, [styles background]))
        {
            CGFloat x1 = round(anchor.x);
            CGFloat x2 = round(_type == kNodeTypeSoftBreak || _type == kNodeTypeNewline ? CGRectGetMaxX(visibleRect) : anchor.x + _width);
            OakRenderFillRect(context, [styles background], CGRectMake(x1, anchor.y, x2 - x1, lineHeight));
        }
    }
}


static void draw_line (CGPoint pos, NSString * text, CGColorRef color, CTFontRef font, CGContextRef context, bool isFlipped)
{
    
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    CFAttributedStringReplaceString(str, CFRangeMake(0, 0), (CFStringRef)text);
    CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTFontAttributeName, font);
    CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTForegroundColorAttributeName, color);
    
    CTLineRef line = CTLineCreateWithAttributedString(str);
    
    CFRelease(str);
    
    CGContextSaveGState(context);
    if(isFlipped)
    {
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, 2 * pos.y));
    }
    
    CGContextSetTextPosition(context, pos.x, pos.y);
    CTLineDraw(line, context);
    CGContextRestoreGState(context);
    
    CFRelease(line);
}


- (void)drawForegroundWithTheme: (OakTheme *)theme
                       fontName: (NSString *)fontName
                       fontSize: (CGFloat)fontSize
                        context: (OakLayoutContext *)context
                      isFlipped: (BOOL)isFlipped
                    visibleRect: (CGRect)visibleRect
                 showInvisibles: (BOOL)showInvisibles
                      textColor: (NSColor *)textColor
                        content: (NSString *)buffer
                         offset: (NSUInteger)bufferOffset
                     misspelled: (NSArray *)misspelled
                         anchor: (CGPoint)anchor
                       baseline: (CGFloat)baseline
{
    if(_line)
    {
        [_line drawForegroundAtPoint: anchor
                             context: context
                             flipped: isFlipped
                          misspelled: misspelled];
    }
    
    if(showInvisibles || (_type != kNodeTypeTab && _type != kNodeTypeNewline))
    {
        NSString * str = nil;
        scope_t scope = buffer.scope(bufferOffset).right;
        switch(_type)
        {
            case kNodeTypeTab:
            {
                str = "‣";
                scope = scope.append("deco.invisible.tab");
                
                break;
            }
            case kNodeTypeNewline:
            {
                str = "¬";
                scope = scope.append("deco.invisible.newline");
                break;
            }
            default:
            {
                break;
            }
        }
        
        if(str)
        {
            styles_t const styles = theme->styles_for_scope(scope, fontName, fontSize);
            
            draw_line(CGPointMake(anchor.x, anchor.y + baseline), str, [styles foreground], [styles font], context, isFlipped);
        }
        
        if(_type == kNodeTypeFolding)
        {
            styles_t const styles = theme->styles_for_scope(scope.append("deco.folding"), fontName, fontSize);
            
            CGFloat x1 = round(anchor.x);
            CGFloat x2 = round(anchor.x + _width);
            CGFloat y2 = round(anchor.y + baseline);
            CGFloat y1 = y2 - round(_width / kFoldingDotsRatio);
            
            CGRect rect = CGRectMake(x1, y1, x2 - x1, y2 - y1);
            if(CGImageRef imageMask = context.folding_dots(CGRectGetWidth(rect), CGRectGetHeight(rect)))
            {
                CGContextSaveGState(context);
                CGContextClipToMask(context, rect, imageMask);
                OakRenderFillRect(context, styles.foreground(), rect);
                CGContextRestoreGState(context);
            }
        }
    }
}

- (OakLayoutLine *)line
{
    return _line;
}

- (void)updateTabWidth: (CGFloat)x
              tabWidth: (CGFloat)tabWidth
               metrics: (OakLayoutMetrics *)metrics
{
    double r = remainder(x, tabWidth);
    
    _width = (r < 0 ? 0 : tabWidth) - r;
    
    if(_width < 0.5 * [metrics columnWidth])
    {
        _width += tabWidth;
    }
}

- (CGFloat)width
{
    return _line ? [_line width] : _width;
}

@end
