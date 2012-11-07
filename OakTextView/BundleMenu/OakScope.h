//
//  OakScope.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakScope : NSObject

- (id)initWithString: (NSString *)str;

- (BOOL)hasPrefix: (OakScope *)rhs;

- (id)scopeByAppendString: (NSString *)str;

- (id)parentScope;

@end
