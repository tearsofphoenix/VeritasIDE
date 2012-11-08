//
//  OakAttributedString.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum
{
    OakAttributedStringStyleBold,
    OakAttributedStringStyleUnbold,
    OakAttributedStringStyleItalic,
    OakAttributedStringStyleUnitalic,
    OakAttributedStringStyleUnderline,
    OakAttributedStringStyleNounderline,
    OakAttributedStringStyleEmboss,
    OakAttributedStringStyleNoemboss,
    
    OakAttributedStringStylePush,
    OakAttributedStringStylePop,
};

typedef NSInteger OakAttributedStringStyleType;

@interface OakAttributedString : NSObject
{
    NSMutableString * _string;
//    struct attr_t
//    {
//        NSUInteger pos;
//        NSString* attr;
//        id value;
//    };
    
    NSMutableArray *_attributes;
}

- (void)addAttribute: (NSString *)attrName
               value: (id)value;

- (NSArray *)attributes;

- (NSString *)string;

- (NSMutableAttributedString *)mutableAttributedString;

- (void)appendString: (NSString *)str;

- (void)appendFont: (NSFont *)font;

- (void)appendShadow: (NSShadow *)shadow;

- (void)appendBackgroundColor: (NSColor *)backgroundColor;

- (void)appendLineBreakMode: (NSLineBreakMode)mode;

- (void)appendImage: (NSImage *)image;

- (void)appendURL: (NSURL *)link;

- (void)appendAttributedString: (OakAttributedString *)str;

@end
