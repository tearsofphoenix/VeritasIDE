//
//  OakSelectionRangeArray.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakSelectionRangeArray.h"
#import "OakSelectionIndex.h"
#import "OakSelectionRange.h"

@implementation OakSelectionRangeArray

- (id)init
{
    return [self initWithRanges: nil];
}

- (id)initWithIndex: (OakSelectionIndex *)index
{
    return [self initWithRanges: @[ [OakSelectionRange rangeWithFirstIndex: index
                                                                 lastIndex: index]] ];
}

- (id)initWithRange: (OakSelectionRange *)range
{
    return [self initWithRanges: @[ range ]];
}

- (id)initWithRanges: (NSArray *)ranges
{
    if ((self = [super init]))
    {
        _ranges = [[NSMutableArray alloc] initWithArray: ranges];
    }
    
    return self;
}

- (void)dealloc
{
    [_ranges release];
    
    [super dealloc];
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return [_ranges isEqualToArray: [object ranges]];
    }
    
    return NO;
}

- (id)firstRange
{
    return [_ranges objectAtIndex: 0];
}

- (id)lastRange
{
    return [_ranges lastObject];
}


- (NSArray *)ranges
{
    return [NSArray arrayWithArray: _ranges];
}

- (BOOL)isEmpty
{
    return [_ranges count] == 0;
}

- (NSUInteger)rangeCount
{
    return [_ranges count];
}

- (void)addRange: (OakSelectionRange *)range
{
    [_ranges addObject: range];
}

- (void)addRangeByIndex: (OakSelectionIndex *)index
{
    [_ranges addObject: [OakSelectionRange rangeWithFirstIndex: index
                                                     lastIndex: index]];
}

- (void)mergeWithRangeArray: (OakSelectionRangeArray *)array
{
    [_ranges addObjectsFromArray: [array ranges]];
}

- (NSUInteger)countByEnumeratingWithState: (NSFastEnumerationState *)state
                                  objects: (id __unsafe_unretained [])buffer
                                    count: (NSUInteger)len
{
    return [_ranges countByEnumeratingWithState: state
                                        objects: buffer
                                          count: len];
}

@end
