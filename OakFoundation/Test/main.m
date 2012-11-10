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
        NSMutableIndexSet *set = [NSMutableIndexSet indexSetWithIndexesInRange: NSMakeRange(5, 10)];
        [set addIndex: 4];
        [set addIndex: 122];
        
        [set enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                          {
                                              NSLog(@"%ld\n", idx);
                                          })];
        
    }
    return 0;
}

