//
//  OakLayoutParagraphNode.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>


enum
{
    kNodeTypeText,
    kNodeTypeTab,
    kNodeTypeUnprintable,
    kNodeTypeFolding,
    kNodeTypeSoftBreak,
    kNodeTypeNewline
};

typedef NSInteger node_type_t;

@class OakLayoutLine;
@class OakTheme;
@class OakLayoutContext;
@class OakLayoutMetrics;

@interface OakLayoutParagraphNode : NSObject
{
    
    OakLayoutLine * _line;
}

@property (nonatomic) node_type_t type;

@property (nonatomic) NSUInteger length;

@property (nonatomic) CGFloat width;

+ (id)nodeWithType: (node_type_t)type
            length: (NSUInteger)length;

- (void)insert: (NSUInteger)i
        length: (NSUInteger)len;

- (void)eraseFrom: (NSUInteger)from
               to: (NSUInteger)to;

- (void)didUpdateScopesFrom: (NSUInteger)from
                         to: (NSUInteger)to;

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
     fillString: (NSString *)fillStr;

- (void)resetFontMetrics: (OakLayoutMetrics *)metrics;

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
                    lineHeight: (CGFloat)lineHeight;

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
                       baseline: (CGFloat)baseline;

- (OakLayoutLine *)line;

- (void)updateTabWidth: (CGFloat)x
              tabWidth: (CGFloat)tabWidth
               metrics: (OakLayoutMetrics *)metrics;

@end

extern NSString * OakStringRepresentationForChar (uint32_t ch);
