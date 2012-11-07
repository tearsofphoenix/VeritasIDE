//
//  NSTask+Executecommand.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "NSTask+Executecommand.h"

@implementation NSTask (Executecommand)

+ (NSString *)resultByExecute: (NSString *)launchPath
                    arguments: (NSArray *)args
                  currentPath: (NSString *)pwd
{
    if (!launchPath)
    {
        return nil;
    }
    
    NSTask *task = [[self alloc] init];
    
    if (pwd)
    {
        [task setCurrentDirectoryPath: pwd];
    }
    
    if (args)
    {
        [task setArguments: args];
    }
    
    [task setLaunchPath: launchPath];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task launch];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSString *str = [[NSString alloc] initWithData: [handle readDataToEndOfFile]
                                          encoding: NSUTF8StringEncoding] ;
    
    
    [task release];
    
    return [str autorelease];
}

@end
