//
//  OakTextSelection.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakTextSelection.h"
#import "OakTextPosition.h"
#import "OakTextRange.h"

@implementation OakTextSelection

- (id)initWithPosition: (OakTextPosition *)position
{
    if ((self = [super init]))
    {
        _ranges = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

- (id)initWithRange: (OakTextRange *)range
{
    if ((self = [super init]))
    {
        _ranges = [[NSMutableArray alloc] init];
        [_ranges addObject: range];
    }
    
    return self;
}

- (id)initWithString: (NSString *)str
{
    if ((self = [super init]))
    {
        NSUInteger from = 0;
        NSUInteger to;
        do
        {
            to = [str rangeOfString: @"&"
                            options: NSLiteralSearch
                              range: NSMakeRange(from, [str length])].location;
            
            OakTextRange *range = [[OakTextRange alloc] initWithString: [str substringWithRange: NSMakeRange(from, (to == NSNotFound ? to : to - from))]];
            
            [_ranges addObject: range];
            
            [range release];
            
            from = to == NSNotFound ? to : to + 1;
            
        } while(to != NSNotFound);
        
//        if([self isEmpty])
//        {
//            ranges.push_back(range_t(0));
//        }
    }
    
    return self;
}

- (NSString *)stringValue
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [_ranges count]];
    
    for (OakTextRange *range in _ranges)
    {
        [array addObject: [range description]];
    }
    
    return [array componentsJoinedByString: @"&"];
}

-(BOOL)isEmpty
{
    return [_ranges count] == 0;
}

- (NSUInteger)count
{
    return [_ranges count];
}

- (void)clear
{
    [_ranges removeAllObjects];
}

- (void)addRange: (OakTextRange *)range
{
    [_ranges addObject: range];
}

@end
