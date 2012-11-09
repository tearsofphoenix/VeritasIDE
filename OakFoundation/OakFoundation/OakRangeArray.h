//
//  OakRangeArray.h
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakRangeArray : NSArray
{
    NSUInteger _count;
    NSRange *_ranges;
}

- (id)normalizedRangeArray;

- (NSUInteger)indexOfRangeContainingOrFollowing: (NSUInteger)arg1;

- (NSUInteger)indexOfRangeContainingOrPreceding: (NSUInteger)arg1;

- (NSUInteger)indexOfRangeFollowing: (NSUInteger)arg1;

- (NSUInteger)indexOfRangePreceding: (NSUInteger)arg1;

- (NSRange)lastRange;

- (NSRange)firstRange;

- (NSUInteger)indexOfRange:(NSRange)arg1;

- (NSRange)rangeAtIndex:(NSUInteger)arg1;

- (id)objectAtIndex: (NSUInteger)arg1;

- (id)initWithRanges: (const NSRange *)arg1
               count: (NSUInteger)arg2;

- (const NSRange *)rangeData;

@end
