//
//  OakSelectionRangeArray.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakSelectionIndex;
@class OakSelectionRange;

@interface OakSelectionRangeArray : NSObject<NSFastEnumeration>
{
    NSMutableArray *_ranges;
}

- (id)initWithIndex: (OakSelectionIndex *)index;

- (id)initWithRange: (OakSelectionRange *)range;

- (id)initWithRanges: (NSArray *)ranges;

- (id)firstRange;

- (id)lastRange;

- (NSArray *)ranges;

- (void)mergeWithRangeArray: (OakSelectionRangeArray *)array;

- (BOOL)isEmpty;

- (NSUInteger)rangeCount;

- (void)addRange: (OakSelectionRange *)range;

- (void)addRangeByIndex: (OakSelectionIndex *)index;

@end
