//
//  OakLayoutLine.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakLayoutLine.h"
#import "theme.h"
#import "OakTextCtype.h"

@implementation OakLayoutLine

- (id)initWithText: (NSString *)text
            scopes: (NSDictionary *)scopes
             theme: (OakTheme *)theme
          fontName: (NSString *)fontName
          fontSize: (CGFloat)fontSize
         textColor: (NSColor *)textColor
{
    if ((self = [super init]))
    {
        
        CFMutableAttributedStringRef toDraw = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        [scopes enumerateKeysAndObjectsUsingBlock: (^(id key, OakScopeContext *obj, BOOL *stop)
                                                    {
                                                        
                                                        id  styles = [theme stylesForScope: obj
                                                                                  fontName: fontName
                                                                                  fontSize: fontSize];
                                                        
                                                        NSUInteger i = [key integerValue];
                                                        
                                                        //NSUInteger j = ++pair != scopes.end() ? pair->first : text.size();
                                                        
                                                        CFMutableAttributedStringRef str = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
                                                        CFAttributedStringReplaceString(str, CFRangeMake(0, 0), cf::wrap(text.substr(i, j - i)));
                                                        CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTFontAttributeName, styles.font());
                                                        CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTForegroundColorAttributeName, textColor ?: styles.foreground());
                                                        CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTLigatureAttributeName, cf::wrap(0));
                                                        if(styles.underlined())
                                                            _underlines.push_back(std::make_pair(CFRangeMake(CFAttributedStringGetLength(toDraw), CFAttributedStringGetLength(str)), CGColorPtr((CGColorRef)CFRetain(styles.foreground()), CFRelease)));
                                                        _backgrounds.push_back(std::make_pair(CFRangeMake(CFAttributedStringGetLength(toDraw), CFAttributedStringGetLength(str)), CGColorPtr((CGColorRef)CFRetain(styles.background()), CFRelease)));
                                                        CFAttributedStringReplaceAttributedString(toDraw, CFRangeMake(CFAttributedStringGetLength(toDraw), 0), str);
                                                        CFRelease(str);
                                                    })];
        
        _line.reset(CTLineCreateWithAttributedString(toDraw), CFRelease);
    }
    
    return self;
}

- (CGFloat)getWidthAscent: (CGFloat *)ascent
                  descent: (CGFloat *)descent
                  leading: (CGFloat *)leading;
{
    return CTLineGetTypographicBounds(_line, ascent, descent, leading);
}

- (NSUInteger)indexForOffset: (CGFloat) offset;
{
    return utf16::advance(_text.data(),
                          CTLineGetStringIndexForPosition(_line, CGPointMake(offset, 0)), _text.data() + _text.size()) - _text.data();
}

- (CGFloat)offsetForIndex: (NSUInteger)index;
{
    return CTLineGetOffsetForStringIndex(_line, utf16::distance(_text.begin(), _text.begin() + index), NULL);
}

static void draw_spelling_dot (OakLayoutContext *  context, CGRect  rect, BOOL isFlipped)
{
    if(CGImageRef spellingDot = context.spelling_dot())
    {
        CGContextSaveGState(context);
        if(isFlipped)
            CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, 2 * rect.origin.y + 3));
        for(CGFloat x = rect.origin.x; x < rect.origin.x + rect.size.width - 0.5; x += 4)
            CGContextDrawImage(context, CGRectMake(x, rect.origin.y, 4, 3), spellingDot);
        CGContextRestoreGState(context);
    }
}

- (void)drawForegroundAtPoint: (CGPoint) pos
                      context: (OakLayoutContext *) context
                      flipped: (BOOL)isFlipped
                   misspelled: (NSArray *)misspelled
{
    iterate(pair, _underlines) // Draw our own underline since CoreText does an awful job <rdar://5845224>
    {
        CGFloat x1 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), pair->first.location, NULL));
        CGFloat x2 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), pair->first.location + pair->first.length, NULL));
        OakRenderFillRect(context, pair->second.get(), CGRectMake(x1, pos.y + 1, x2 - x1, 1));
    }
    
    iterate(pair, misspelled)
    {
        CFIndex location = utf16::distance(_text.begin(),               _text.begin() + pair->first);
        CFIndex length   = utf16::distance(_text.begin() + pair->first, _text.begin() + pair->second);
        CGFloat x1 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), location, NULL));
        CGFloat x2 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), location + length, NULL));
        draw_spelling_dot(context, CGRectMake(x1, pos.y + 1, x2 - x1, 3), isFlipped);
    }
    
    CGContextSaveGState(context);
    if(isFlipped)
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, 2 * pos.y));
    CGContextSetTextPosition(context, pos.x, pos.y);
    CTLineDraw(_line.get(), context);
    CGContextRestoreGState(context);
}

- (void)drawBackgroundAtPoint: (CGPoint)pos
                       height: (CGFloat)height
                      context: (OakLayoutContext *)context
                      flipped: (BOOL)isFlipped
              backgroundColor: (NSColor *)currentBackground;
{
    iterate(pair, _backgrounds)
    {
        if(CFEqual(currentBackground, pair->second.get()))
            continue;
        
        CGFloat x1 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), pair->first.location, NULL));
        CGFloat x2 = round(pos.x + CTLineGetOffsetForStringIndex(_line.get(), pair->first.location + pair->first.length, NULL));
        OakRenderFillRect(context, pair->second.get(), CGRectMake(x1, pos.y, x2 - x1, height));
    }
}

@end
