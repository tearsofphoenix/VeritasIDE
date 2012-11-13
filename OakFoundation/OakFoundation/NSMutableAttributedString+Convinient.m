//
//  NSMutableAttributedString+Convinient.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "NSMutableAttributedString+Convinient.h"

@implementation NSMutableAttributedString (Convinient)


- (void)setForegroundColor: (NSColor *)foregroundColor
                     range: (NSRange)range
{
    [self addAttribute: NSForegroundColorAttributeName
                 value: foregroundColor
                 range: range];
}

- (void)setBackgroundColor: (NSColor *)backgroundColor
                     range: (NSRange)range
{
    [self addAttribute: NSBackgroundColorAttributeName
                 value: backgroundColor
                 range: range];
}

- (void)setBaselineOffset: (CGFloat)offset
                    range: (NSRange)range
{
    [self addAttribute: NSBaselineOffsetAttributeName
                 value:  @(offset)
                 range: range];
}

- (void)setFont: (NSFont *)font
          range: (NSRange)range
{
    [self addAttribute: NSFontAttributeName
                 value: font
                 range: range];
}

- (void)setKerning: (CGFloat)kerning
             range: (NSRange)range
{
    [self addAttribute: NSKernAttributeName
                 value: @(kerning)
                 range: range];
}

- (void)setLink: (NSURL *)link
          range: (NSRange)range
{
    [self addAttribute: NSLinkAttributeName
                  value: link
                  range: range];
}

- (void)setParagraphStyle: (NSParagraphStyle *)style
                    range: (NSRange)range
{
    [self addAttribute: NSParagraphStyleAttributeName
                  value: style
                  range: range];
}

- (void)setLigature: (OakAttributedStringLigatureType)ligatureType
              range: (NSRange)range
{
    [self addAttribute: NSLigatureAttributeName
                  value: @(ligatureType)
                  range: range];
}

- (void)setUnderlineStyle: (NSUInteger)underlineStyle
                    range: (NSRange)range
{
    [self addAttribute: NSUnderlineStyleAttributeName
                  value: @(underlineStyle)
                  range: range];
}

//NSString *NSSuperscriptAttributeName;
//NSString *NSAttachmentAttributeName;
- (void)setStoreWidth: (CGFloat)width
                range: (NSRange)range
{
    [self addAttribute: NSStrokeWidthAttributeName
                  value: @(width)
                  range: range];
}

- (void)setStoreColor: (NSColor *)color
                range: (NSRange)range
{
    [self addAttribute: NSStrokeColorAttributeName
                  value: color
                  range: range];
}


- (void)setUnderlineColor: (NSColor *)color
                    range: (NSRange)range
{
    [self addAttribute: NSUnderlineColorAttributeName
                  value: color
                  range: range];
}

//NSString *NSStrikethroughStyleAttributeName;
//NSString *NSStrikethroughColorAttributeName;

- (void)setShadow: (CGSize)shadowOffset
       blurRadius: (CGFloat)radius
            color: (NSColor *)color
            range: (NSRange)range
{
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius: radius];
    [shadow setShadowColor: color];
    [shadow setShadowOffset: shadowOffset];
    
    [self addAttribute: NSShadowAttributeName
                  value: shadow
                  range: range];
    
    [shadow release];
}

//NSString *NSObliquenessAttributeName;
//NSString *NSExpansionAttributeName;
//NSString *NSCursorAttributeName;

- (void)setToolTip: (NSString *)toolTip
             range: (NSRange)range
{
    [self addAttribute: NSToolTipAttributeName
                  value: toolTip
                  range: range];
}

- (void)setMarkedClauseSegment: (NSUInteger)idx
                         range: (NSRange)range
{
    [self addAttribute: NSMarkedClauseSegmentAttributeName
                  value: @(idx)
                  range: range];
}

@end
