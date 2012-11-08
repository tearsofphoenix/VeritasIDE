//
//  OakDocumentScanner.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentScanner.h"

@implementation OakDocumentScanner

- (id)initWithPath: (NSString *)path
              glob: (id)glob
{
    if ((self = [super init]))
    {
        _path = [path retain];
        _glob = [glob retain];
        _followLinks = NO;
        _depthFirst = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)isRunning
{
    return _is_running_flag;
}

- (void)stop
{
    _should_stop_flag = YES;
}

- (void)wait
{
    pthread_join(thread, NULL);
}
    
+ (NSArray *)openDocuments
{
    
}

- (NSArray *)acceptDocuments
{
    
}

- (NSString *)currentPath
{
    
}

@end
