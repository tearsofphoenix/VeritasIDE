//
//  NSTask+Executecommand.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (Executecommand)

+ (NSString *)resultByExecute: (NSString *)launchPath
                    arguments: (NSArray *)args
                  currentPath: (NSString *)pwd;

@end
