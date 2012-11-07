//
//  NSDictionary+KeyPathSupport.m
//  OakFoundation
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "NSDictionary+KeyPathSupport.h"

@implementation NSDictionary (KeyPathSupport)


- (id)objectForKeyPath: (NSString *)keyPath
{
    NSArray *paths = [keyPath componentsSeparatedByString: @"."];
    
    id dictLooper = nil;
    NSDictionary *source = self;
    
    for (id keyLooper in paths)
    {
        dictLooper = [source objectForKey: keyLooper];
        
        source = dictLooper;
    }
    
    return dictLooper;
}

@end
