//
//  main.m
//  Test
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OakFoundation/OakFoundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool
    {
        NSArray *a = @[ @"x", @"Y", @"Z"];
        
        NSArray *b = @[ @"ad", @"Y", @1];
        
        
        NSLog(@"%@", [a differenceArrayWithArray: b]);
        NSLog(@"%@", [a intersectArrayWithArray: b]);
        
    }
    return 0;
}

