//
//  OakDocumentWatch.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTE_RENAME 0
#define NOTE_WRITE 1
#define NOTE_DELETE 2
#define NOTE_ATTRIB 4
#define NOTE_REVOKE 8

#ifndef NOTE_CREATE
#define NOTE_CREATE (NOTE_REVOKE << 1)
#endif

@interface OakDocumentWatchBase : NSObject
{
    NSUInteger client_id;
}

- (id)initWithPath: (NSString *)path;


- (void)callbackWithFlag: (NSInteger)flags
                    path: (NSString *)newPath;

@end


@interface OakDocumentWatch : NSObject

@end
