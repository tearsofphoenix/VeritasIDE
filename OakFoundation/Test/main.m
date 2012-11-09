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
        OakMutableRangeArray *rangeArray = [[OakMutableRangeArray alloc] init];
        [rangeArray addRange: NSMakeRange(0, 1)];
        [rangeArray addObject: @"{10,10}"];
        [rangeArray firstRange];
        NSLog(@"%@", rangeArray);
        
        id obj = @[ @"YE"];
        id co = [obj mutableCopy];
        
        NSLog(@"%d", [obj isEqualToArray: co]);
        
    }
    return 0;
}

