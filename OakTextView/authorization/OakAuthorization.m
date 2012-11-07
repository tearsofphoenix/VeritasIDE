//
//  OakAuthorization.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakAuthorization.h"

#import "OakAuthorizationHelper.h"

@implementation OakAuthorization

- (id)initWithHexString: (NSString *)str
{
    if ((self = [super init]))
    {
        _private = [[OakAuthorizationHelper alloc] initWithHexString: str];
    }
    
    return self;
}

- (void)dealloc
{
    [_private release];
    
    [super dealloc];
}

- (BOOL)checkRight: (NSString *)right
{
    return [_private copyright: right
                          flag: kAuthorizationFlagDefaults];
}

- (BOOL)obtainRight: (NSString *)right
{
    return [_private copyright: right
                          flag: (kAuthorizationFlagInteractionAllowed
                                 |kAuthorizationFlagExtendRights)];
}

- (AuthorizationRef)reference
{
    return [_private reference];
}

- (NSString *)description
{
    return [_private description];
}

@end
