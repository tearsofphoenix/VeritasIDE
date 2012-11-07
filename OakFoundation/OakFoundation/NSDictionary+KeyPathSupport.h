//
//  NSDictionary+KeyPathSupport.h
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KeyPathSupport)

- (id)objectForKeyPath: (NSString *)keyPath;

@end
