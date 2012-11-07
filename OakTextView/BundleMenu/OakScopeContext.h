//
//  OakScopeContext.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakScope;

@interface OakScopeContext : NSObject
{
    OakScope *_left;
    OakScope *_right;
}


- (id)initWithString: (NSString *)str;

- (id)initWithScope: (OakScope *)scope;

- (id)initWithLeftScope: (OakScope *)leftScope
             rightScope: (OakScope *)rightScope;


@end
