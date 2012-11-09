//
//  OakMutableRectArray.h
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakMutableRectArray : NSMutableArray


- (void)removeAllRects;

- (void)removeRectsAtIndexes: (NSIndexSet *)indexes;

- (void)removeRectAtIndex:(NSUInteger)idx;

- (void)insertRect: (NSRect)rect
           atIndex: (NSUInteger)idx;

- (void)addRect:(NSRect)rect;

- (void)setRect: (NSRect)rect
        atIndex: (NSUInteger)idx;

- (NSRect)lastRect;

- (NSRect)firstRect;

- (NSUInteger)indexOfRect:(NSRect)rect;

- (NSRect)rectAtIndex: (NSUInteger)idx;

- (id)initWithRects:(const NSRect *)rects
              count:(NSUInteger)idx;

- (id)initWithObjects: (id *)objects
                count: (NSUInteger)idx;

- (id)initWithCapacity: (NSUInteger)cap;

- (const void *)rectData;

@end
