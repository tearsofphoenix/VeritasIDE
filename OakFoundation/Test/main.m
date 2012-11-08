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
        NSString *test = @"测试1";
        printf("%s\n", [test UTF8String]);
        for (NSUInteger iLooper = 0; iLooper < [test length]; ++iLooper)
        {
            NSLog(@"%ld char: %C", iLooper, ([test characterAtIndex: iLooper]));
        }
        
        const char *cStirng = [test UTF8String];
        while(*cStirng)
        {
            printf("%c\n", *cStirng);
            ++cStirng;
        }

    }
    return 0;
}

