//
//  OakLayoutMetrics.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakLayoutMetrics.h"


@implementation OakLayoutMetrics

- (id)initWithFontName: (NSString *)fontName
              fontSize: (CGFloat)size
{
    if((self = [super init]))
    {
        CTFontRef font = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
        CFMutableAttributedStringRef str = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(str, CFRangeMake(0, 0), CFSTR("n"));
        CFAttributedStringSetAttribute(str, CFRangeMake(0, CFAttributedStringGetLength(str)), kCTFontAttributeName, font);
        CTLineRef line = CTLineCreateWithAttributedString(str);
        
        _ascent       = CTFontGetAscent(font);
        _descent      = CTFontGetDescent(font);
        _leading      = CTFontGetLeading(font);
        _xHeight     = CTFontGetXHeight(font);
        _capHeight   = CTFontGetCapHeight(font);
        _columnWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _ascentDelta  = [[defaults objectForKey: @"fontAscentDelta"] doubleValue];
        _leadingDelta = [[defaults objectForKey: @"fontLeadingDelta"] doubleValue];
        
        CFRelease(line);
        CFRelease(str);
        CFRelease(font);
    }
    
    return self;
}


- (CGFloat)baseline: (CGFloat)minAscent
{
    return round(MIN(minAscent, _ascent) + _ascentDelta);
}

- (CGFloat)lineHeightWithMinAscent: (CGFloat) minAscent
                        minDescent: (CGFloat) minDescent
                        minLeading: (CGFloat) minLeading
{
    CGFloat ascent  = MAX(minAscent, _ascent) + _ascentDelta;
    CGFloat descent = MAX(minDescent, _descent);
    CGFloat leading = MAX(minLeading, _leading) + _leadingDelta;
    
    return ceil(ascent + descent + leading);
}

@end
