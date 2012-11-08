//
//  OakCompletionInfo.m
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakCompletionInfo.h"

@implementation OakCompletionInfo

- (id)init
{
    if ((self = [super init]))
    {
        _suggestions = [[NSMutableArray alloc] init];
        _revision = 0;
        _index = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [_suggestions release];
    [_ranges release];
    [_prefixRanges release];
    
    [super dealloc];
}

@synthesize revision = _revision;
@synthesize ranges = _ranges;
@synthesize prefixRanges = _prefixRanges;
@synthesize suggestions = _suggestions;

- (void)setSuggestions: (NSArray *)suggestions
{
    if (_suggestions != suggestions)
    {
        [_suggestions setArray: suggestions];
        _index = [_suggestions count];
    }
}

- (NSString *)current
{
    return [_suggestions objectAtIndex: _index];
}

- (void)advance
{
    if (++_index >= [_suggestions count])
    {
        _index = 0;
    }
}

- (void)retreat
{
    if (--_index < 0)
    {
        _index = [_suggestions count] - 1;
    }
}

@end
