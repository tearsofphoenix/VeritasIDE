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

@interface OakSelectionRangeArray : NSObject
{
    NSMutableArray *_ranges;
}

- (id)initWithIndex: (OakSelectionIndex *)index;

- (id)initWithRange: (OakSelectionRange *)range;

- (id)initWithRanges: (NSArray *)ranges;


- (NSArray *)ranges;

- (BOOL)isEmpty;

- (NSUInteger)rangeCount;

- (void)addRange: (OakSelectionRange *)range;

- (void)addRangeByIndex: (OakSelectionIndex *)index;

@end
