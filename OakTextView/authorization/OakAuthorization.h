//
//  OakAuthorization.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakAuthorizationHelper;

@interface OakAuthorization : NSObject
{
@private
    OakAuthorizationHelper *_private;
}

- (id)initWithHexString: (NSString *)str;

- (BOOL)checkRight: (NSString *)right;

- (BOOL)obtainRight: (NSString *)right;

- (AuthorizationRef)reference;

@end
