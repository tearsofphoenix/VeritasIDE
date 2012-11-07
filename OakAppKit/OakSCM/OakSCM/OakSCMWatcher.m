//
//  OakSCMWatcher.m
//  OakSCM
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakSCMWatcher.h"

@interface OakSCMWatcher ()
{
@private
    dispatch_source_t _source;
    FILE *_file;
    BOOL _isObserving;
}
@end

@implementation OakSCMWatcher

static const char * OakSCMWatcherQueueID = "com.veritas.framework.scm.queue.watcher";

static dispatch_queue_t s_OakSCMWatcherQueue = NULL;

+ (void)initialize
{
    if (!s_OakSCMWatcherQueue)
    {
        s_OakSCMWatcherQueue = dispatch_queue_create(OakSCMWatcherQueueID, DISPATCH_QUEUE_CONCURRENT);
    }
}

- (id)initWithPath: (NSString *)path
{
    if ((self = [super init]))
    {
        [self setPath: path];
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_source);
    
    [_path release];
    
    Block_release(_cancelBlock);
    Block_release(_callback);
    
    [super dealloc];
}

@synthesize path = _path;

- (void)setPath: (NSString *)path
{
    if (_path != path)
    {
        [_path release];
        _path = [path retain];
        
        if (_file)
        {
            fclose(_file);
        }
        
        if (_path)
        {
            _file = fopen([_path UTF8String], "r");
            
            int lf_dup = dup(fileno(_file));
            
            // We register the vnode callback on the qpf queue since that is where
            // we do all our logfile printing.   (we set up to reopen the logfile
            // if the "old one" has been deleted or renamed (or revoked).  This
            // makes it pretty safe to mv the file to a new name, delay breifly,
            // then gzip it.   Safer to move the file to a new name, wait for the
            // "old" file to reappear, then gzip.   Niftier then doing the move,
            // sending a SIGHUP to the right process (somehow) and then doing
            
            _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                             lf_dup,
                                             (DISPATCH_VNODE_DELETE
                                              | DISPATCH_VNODE_WRITE
                                              | DISPATCH_VNODE_EXTEND
                                              | DISPATCH_VNODE_ATTRIB
                                              | DISPATCH_VNODE_LINK
                                              | DISPATCH_VNODE_RENAME
                                              | DISPATCH_VNODE_REVOKE),
                                             s_OakSCMWatcherQueue);            
        }
    }
}

@synthesize callback = _callback;

- (void)setCallback: (OakSCMWatchCallback)callback
{
    if (_callback != callback)
    {
        Block_release(_callback);
        _callback = Block_copy(callback);
        
        dispatch_source_set_event_handler(_source,
                                          (^(void)
                                           {
                                               if (_callback)
                                               {
                                                   OakSCMFileEvent event = dispatch_source_get_data(_source);
                                                   _callback(_path, event);
                                               }
                                           }));
    }
}

@synthesize cancelBlock = _cancelBlock;

- (void)setCancelBlock: (dispatch_block_t)cancelBlock
{
    if (_cancelBlock != cancelBlock)
    {
        Block_release(_cancelBlock);
        _cancelBlock = Block_copy(_cancelBlock);
        
        dispatch_source_set_cancel_handler(_source, _cancelBlock);
    }
}

- (BOOL)isObserving
{
    return _isObserving;
}

- (void)start
{
    if (!_isObserving)
    {
        dispatch_resume(_source);
        _isObserving = YES;
    }
}

- (void)stop
{
    if (_isObserving)
    {
        dispatch_suspend(_source);        
        _isObserving = NO;
    }
}

@end
