//
//  OakDocumentScanner.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakDocumentScanner : NSObject
{
    NSString * _path;
    id _glob;
    BOOL _followLinks;
    BOOL _depthFirst;
    
    pthread_t thread;
    pthread_mutex_t mutex;
    BOOL _is_running_flag;
    BOOL _should_stop_flag;
    
    NSString * _current_path;
    NSMutableArray *_documents;
    NSMutableSet *_seen_paths;
}


- (id)initWithPath: (NSString *)path
              glob: (id)glob;

- (BOOL)isRunning;

- (void)stop;

- (void)wait;

+ (NSArray *)openDocuments;

- (NSArray *)acceptDocuments;

- (NSString *)currentPath;

@end
