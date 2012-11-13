//
//  NSMutableAttributedString+Convinient.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    OakAttributedStringNoLigature = 0,
    OakAttributedStringDefaultLigature = 1,
    OakAttributedStringAllLigature = 2,
};

typedef NSUInteger OakAttributedStringLigatureType;

@interface NSMutableAttributedString (Convinient)

- (void)setForegroundColor: (NSColor *)foregroundColor
                     range: (NSRange)range;

- (void)setBackgroundColor: (NSColor *)backgroundColor
                     range: (NSRange)range;

- (void)setBaselineOffset: (CGFloat)offset
                    range: (NSRange)range;

- (void)setFont: (NSFont *)font
          range: (NSRange)range;

- (void)setKerning: (CGFloat)kerning
             range: (NSRange)range;

- (void)setLink: (NSURL *)link
          range: (NSRange)range;

- (void)setParagraphStyle: (NSParagraphStyle *)style
                    range: (NSRange)range;


- (void)setLigature: (OakAttributedStringLigatureType)ligatureType
              range: (NSRange)range;

- (void)setUnderlineStyle: (NSUInteger)underlineStyle
                    range: (NSRange)range;

//NSString *NSSuperscriptAttributeName;
//NSString *NSAttachmentAttributeName;
- (void)setStoreWidth: (CGFloat)width
                range: (NSRange)range;

- (void)setStoreColor: (NSColor *)color
                range: (NSRange)range;


- (void)setUnderlineColor: (NSColor *)color
                    range: (NSRange)range;

//NSString *NSStrikethroughStyleAttributeName;
//NSString *NSStrikethroughColorAttributeName;

- (void)setShadow: (CGSize)shadowOffset
       blurRadius: (CGFloat)radius
            color: (NSColor *)color
            range: (NSRange)range;

//NSString *NSObliquenessAttributeName;
//NSString *NSExpansionAttributeName;
//NSString *NSCursorAttributeName;

- (void)setToolTip: (NSString *)toolTip
             range: (NSRange)range;

- (void)setMarkedClauseSegment: (NSUInteger)idx
                         range: (NSRange)range;

//NSString *NSWritingDirectionAttributeName;
//NSString *NSVerticalGlyphFormAttributeName;
//NSString *NSTextAlternativesAttributeName;

@end
