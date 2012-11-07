//
//  OakAuthorizationHelper.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakAuthorizationHelper : NSObject

- (id)initWithHexString: (NSString *)hexString;

- (BOOL)copyright: (NSString *)right
             flag: (AuthorizationFlags)flags;

- (AuthorizationRef)reference;

@end
