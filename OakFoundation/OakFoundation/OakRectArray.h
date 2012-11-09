//
//  OakRectArray.h
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakRectArray : NSArray
{
    NSUInteger _count;
    NSRect *_rects;
}

- (NSRect)lastRect;

- (NSRect)firstRect;

- (NSUInteger)indexOfRect: (NSRect)rect;

- (NSRect)rectAtIndex: (NSUInteger)rect;

- (id)objectAtIndex: (NSUInteger)arg1;

- (NSUInteger)count;

- (id)descriptionWithLocale: (NSLocale *)locale;

- (id)mutableCopyWithZone: (NSZone *)zone;

- (id)copyWithZone: (NSZone *)zone;

- (BOOL)isEqualToArray:(id)arg1;

- (id)initWithRects: (const NSRect *)rects
              count: (NSUInteger)count;

- (id)initWithObjects: (const id *)objects
                count: (NSUInteger)count;

- (const NSRect *)rectData;

@end
