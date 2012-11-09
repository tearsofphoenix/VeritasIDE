//
//  OakMutableRangeArray.h
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakMutableRangeArray : NSMutableArray

- (void)normalize;

- (void)removeAllRanges;

- (void)removeRangesAtIndexes: (NSIndexSet *)indexes;

- (void)removeRangeAtIndex:(NSUInteger)arg1;

- (void)insertRange:(NSRange)arg1 atIndex:(NSUInteger)arg2;

- (void)addRange:(NSRange)arg1;

- (void)setRange:(NSRange)arg1 atIndex:(NSUInteger)arg2;

- (NSUInteger)indexOfRangeContainingOrFollowing:(NSUInteger)arg1;

- (NSUInteger)indexOfRangeContainingOrPreceding:(NSUInteger)arg1;

- (NSUInteger)indexOfRangeFollowing:(NSUInteger)arg1;

- (NSUInteger)indexOfRangePreceding:(NSUInteger)arg1;

- (NSRange)lastRange;

- (NSRange)firstRange;

- (NSUInteger)indexOfRange:(NSRange)arg1;

- (NSRange)rangeAtIndex:(NSUInteger)arg1;

- (id)initWithRanges:(const NSRange *)arg1 count:(NSUInteger)arg2;

- (id)initWithObjects:(id *)arg1 count:(NSUInteger)arg2;

- (id)initWithCapacity:(NSUInteger)arg1;

- (const NSRange *)rangeData;

@end
