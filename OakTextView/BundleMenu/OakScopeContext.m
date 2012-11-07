//
//  OakScopeContext.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakScopeContext.h"
#import "OakScope.h"

@implementation OakScopeContext

- (id)initWithString: (NSString *)str
{
    if ((self = [super init]))
    {
        _left = [[OakScope alloc] initWithString: str];
        _right = [[OakScope alloc] initWithString: str];
    }
    
    return self;
}

- (id)initWithScope: (OakScope *)scope
{
    if ((self = [super init]))
    {
        _left = [scope retain];
        _right = [scope retain];
    }
    
    return self;
}

- (id)initWithLeftScope: (OakScope *)leftScope
             rightScope: (OakScope *)rightScope
{
    if ((self = [super init]))
    {
        _left = [leftScope retain];
        _right = [rightScope retain];
    }
    
    return self;
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return [_left isEqual: [object leftScope]] && [_right isEqual: [object rightScope]];
    }
    
    return NO;
}

@end
