//
//  XCSourceTokens.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-10.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCSourceTokens.h"

@implementation XCSourceTokens

+ (NSInteger)addTokenForString: (NSString *)arg1
{
    return 0;
}

+ (NSInteger)_tokenForString: (NSString *)arg1
{
    return 0;
}

- (NSSet *)allTokens
{
    return [NSSet setWithSet: _tokens];
}

- (NSInteger)tokenForString: (NSString *)arg1
{
    return 0;
}

- (BOOL)containsToken: (id)arg1
{
    if (_caseSensitive)
    {
        return [_tokens containsObject: arg1];
    }else
    {
        for (NSString *iLooper in _tokens)
        {
            if ([iLooper compare: arg1
                         options: NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                return YES;
            }
        }
        
        return NO;
    }
}

- (void)setCaseSensitive: (BOOL)arg1
{
    _caseSensitive = arg1;
}

- (void)addArrayOfStrings: (NSArray *)strs
{
    [_tokens addObjectsFromArray: strs];
}

- (void)dealloc
{
    [_tokens release];
    
    [super dealloc];
}

- (id)initWithArrayOfStrings: (NSArray *)strs
               caseSensitive: (BOOL)flag
{
    if ((self = [super init]))
    {
        _tokens = [[NSMutableSet alloc] initWithCapacity: [strs count]];
        _caseSensitive = flag;
        
        [self addArrayOfStrings: strs];
    }
    
    return self;
}

@end