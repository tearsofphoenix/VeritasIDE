//
//  OakLayoutParagraph.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OakLayoutParagraphNode.h"

@class OakLayoutContext;
@class OakSelectionRangeArray;
@class OakSelectionIndex;

@interface OakLineRecord : NSObject

+ (id)lineRecordWithLine: (NSUInteger)line
                softLine: (NSUInteger)softLine
                     top: (CGFloat)top
                  bottom: (CGFloat)bottom
                baseline: (CGFloat)baseline;

@property (nonatomic) NSUInteger line;
@property (nonatomic) NSUInteger softline;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat baseline;

@end

@interface OakLayoutParagraph : NSObject


- (NSUInteger)length;


- (void)insertContent: (NSString *)buffer
           atPosition: (NSUInteger)pos
               length: (NSUInteger)len
               offset: (NSUInteger)offset;
    


- (void)insertFoldedContent: (NSString *)buffer
                 atPosition: (NSUInteger)pos
                     length: (NSUInteger)len
                     offset: (NSUInteger)offset;
    


- (void)eraseContent: (NSString *)buffer
                from: (NSUInteger)from
                  to: (NSUInteger)to
              offset: (NSUInteger)offset;
    


- (void)didUpdateScopesOfContent: (NSString *)buffer
                            from: (NSUInteger)from
                              to: (NSUInteger)to
                          offset: (NSUInteger)offset;
    


- (BOOL)layoutWithTheme: (OakTheme *)theme
               fontName: (NSString *)fontName
               fontSize: (CGFloat)fontSize
               softWrap: (BOOL)softWrap
             wrapColumn: (NSUInteger)wrapColumn
                metrics: (OakLayoutMetrics *)metrics
            visibleRect: (CGRect)visibleRect
                content: (NSString * ) buffer
                 offset: (NSUInteger)bufferOffset;
    



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
                         anchor: (CGPoint) anchor;
    


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
                         anchor: (CGPoint) anchor;
    


- (OakSelectionIndex *)indexAtPoint: (CGPoint)point
                            metrics: (OakLayoutMetrics *)metrics
                            content: (NSString *)buffer
                             offset: (NSUInteger)bufferOffset
                             anchor: (CGPoint)anchor;
    


- (CGRect)rectAtIndex: (OakSelectionIndex *)index
              metrics: (OakLayoutMetrics *)metrics
               buffer: (NSString *)buffer
               offset: (NSUInteger)bufferOffset
               anchor: (CGPoint)anchor;
    


- (OakLineRecord *)lineRecordFor: (NSUInteger)line
                        position: (NSUInteger)pos
                         metrics: (OakLayoutMetrics *)metrics
                          buffer: (NSString *)buffer
                          offset: (NSUInteger)bufferOffset
                          anchor: (CGPoint)anchor;
    


- (NSUInteger)beginOfLine: (NSUInteger)index
                  content: (NSString *)buffer
                   offset: (NSUInteger)bufferOffset;
    


- (NSUInteger)endOfLine: (NSUInteger)index
                content: (NSString *)buffer
                 offset: (NSUInteger)bufferOffset;
    


- (NSUInteger)indexLeftOf: (NSUInteger)index
                  content: (NSString *)buffer
                   offset: (NSUInteger)bufferOffset;
    


- (NSUInteger)indexRightOf: (NSUInteger)index
                   content: (NSString *)buffer
                    offset: (NSUInteger)bufferOffset;
    


- (void)setWrapping: (BOOL)softWrap
         wrapColumn: (NSUInteger)wrapColumn
            metrics: (OakLayoutMetrics *)metrics;
    
    


- (void)setTabSize: (NSUInteger)tabSize
           metrics: (OakLayoutMetrics *)metrics;
    


- (void)resetFontWithMetrics: (OakLayoutMetrics *)metrics;
    


- (CGFloat)width;
    


- (CGFloat)heightWithMetrics: (OakLayoutMetrics *)metrics;
    

- (BOOL)structuralIntegrity;

- (OakLayoutParagraphNode *)nodeAt: (NSUInteger) i;


- (void)insertTextAt: (NSUInteger) i
              length: (NSUInteger)len;
    


- (void)insertTabAt: (NSUInteger) i;
    


- (void)insertUnprintableAt: (NSUInteger) i
                     length: (NSUInteger)len;
    


- (void)insertNewlineAt: (NSUInteger)i
                 length: (NSUInteger)len;
    


- (NSArray *)softLinesWithMetrics: (OakLayoutMetrics *)metrics
                   breakOnNewLine: (BOOL)softBreaksOnNewline;
    



@end
