//
//  OakLayoutLine.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakTheme;
@class OakLayoutContext;

@interface OakLayoutLine : NSObject
{
    NSString * _text;
    CTLineRef _line;
    NSMutableArray *_backgrounds;
    NSMutableArray *_underlines;

}

- (id)initWithText: (NSString *)text
            scopes: (NSDictionary *)scopes
             theme: (OakTheme *)theme
          fontName: (NSString *)fontName
          fontSize: (CGFloat)fontSize
         textColor: (NSColor *)textColor;

- (void)drawForegroundAtPoint: (CGPoint) pos
                      context: (OakLayoutContext *) context
                        flipped: (BOOL)isFlipped
                   misspelled: (NSArray *)misspelled;

- (void)drawBackgroundAtPoint: (CGPoint)pos
                       height: (CGFloat)height
                      context: (OakLayoutContext *)context
                      flipped: (BOOL)isFlipped
              backgroundColor: (NSColor *)currentBackground;


- (CGFloat)getWidthAscent: (CGFloat *)ascent
                  descent: (CGFloat *)descent
                  leading: (CGFloat *)leading;

- (NSUInteger)indexForOffset: (CGFloat) offset;

- (CGFloat)offsetForIndex: (NSUInteger)index;

@end
