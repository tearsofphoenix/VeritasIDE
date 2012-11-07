//
//  OakSCMWatcher.h
//  OakSCM
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    OakSCMFileEventDelete =	0x1,
    OakSCMFileEventWrite  =	0x2,
    OakSCMFileEventExtend = 0x4,
    OakSCMFileEventAttrib = 0x8,
    OakSCMFileEventLink   = 0x10,
    OakSCMFileEventRename =	0x20,
    OakSCMFileEventRevoke = 0x40,
};

typedef NSInteger OakSCMFileEvent;

typedef void (^OakSCMWatchCallback)(NSString *path, OakSCMFileEvent event);

@interface OakSCMWatcher : NSObject

- (id)initWithPath: (NSString *)path;

@property (nonatomic, retain) NSString *path;

@property (nonatomic, copy) OakSCMWatchCallback callback;

@property (nonatomic, copy) dispatch_block_t cancelBlock;

- (BOOL)isObserving;

- (void)start;

- (void)stop;

@end
