//
//  OakDocumentWatch.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentWatch.h"
#import <pthread.h>

@interface OakDocumentWatchInfo : NSObject

@property (nonatomic, retain) NSString *path;

@property (nonatomic, retain) NSString *watchedPath;

@property (nonatomic) NSInteger fd;

@end

@interface OakDocumentWatchServer : NSObject<NSStreamDelegate>
{
    NSMutableDictionary *_clients;
    NSUInteger next_client_id;
    
    // used for book-keeping in server thread
    NSMutableDictionary *_watchInfos;
    
    pthread_t server_thread;
    int event_queue;
    NSOutputStream *read_from_server_pipe;
    NSOutputStream *write_to_master_pipe;
    NSOutputStream *read_from_master_pipe;
    NSOutputStream *write_to_server_pipe;
}

- (NSUInteger)addClient: (NSString *)path
               callback: (OakDocumentWatchBase *)callback;

- (void)removeClient: (NSUInteger)clientID;

- (void)run;

- (void)addClient: (NSUInteger)clientID
             path: (NSString *)path;


- (void)observeInfo: (OakDocumentWatchInfo *)info
           clientID: (NSUInteger)clinetID;

- (void)data_from_server;

@end

@implementation OakDocumentWatchServer

static void* server_run_stub (void* arg)
{
    [(OakDocumentWatchServer *)arg run];
    return NULL;
}

static OakDocumentWatchServer *s_OakDocumentWatchSharedServer = nil;

+ (id)sharedServer
{
    if (!s_OakDocumentWatchSharedServer)
    {
        s_OakDocumentWatchSharedServer = [[OakDocumentWatchServer alloc] init];
    }
    
    return s_OakDocumentWatchSharedServer;
}

- (id)init
{
    if ((self = [super init]))
    {
        next_client_id = 1;
        
//        read_from_master_pipe
//        io::create_pipe(read_from_server_pipe, write_to_master_pipe, true);
//        io::create_pipe(read_from_master_pipe, write_to_server_pipe, true);
        read_from_server_pipe = [[NSOutputStream alloc] init];
        [read_from_server_pipe setDelegate: self];
        
        pthread_create(&server_thread, NULL, &server_run_stub, self);
        
        // attach to run-loop
//        CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault, read_from_server_pipe, kCFSocketReadCallBack, &data_from_server_stub, NULL);
//        
//        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
//        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
//        
//        CFRelease(source);
//        CFRelease(socket);

    }
    
    return self;
}

- (void)dealloc
{
    [write_to_server_pipe close];  // tell server to shutdown
    [read_from_server_pipe close]; // causes server to get -1 when sending us data, another way to tell it to quit
    
    pthread_join(server_thread, NULL);
    
    [super dealloc];
}


// ==================
// = watch_server_t =
// ==================


// ============================
// = Running in master thread =
// ============================

- (NSUInteger)addClient: (NSString *)path
               callback: (OakDocumentWatchBase *)callback
{
    //D(DBF_Document_WatchFS, bug("%zu: %s — %p\n", next_client_id, path.c_str(), callback););
    [_clients setObject: callback
                 forKey: @(next_client_id)];

//    struct
//    { NSUInteger client_id;
//        NSString ** path;
//    }
//    packet =
//    {
//        next_client_id, new NSString *(path)
//    };
//    write(write_to_server_pipe, &packet, sizeof(packet));
    return next_client_id++;
}

- (void)removeClient:(NSUInteger)clientID
{
    //D(DBF_Document_WatchFS, bug("%zu\n", client_id););
    [_clients removeObjectForKey: @(clientID)];
    [_watchInfos removeObjectForKey: @(clientID)];

//    struct { NSUInteger client_id; NSString ** path; } packet = { client_id, NULL };
//    write(write_to_server_pipe, &packet, sizeof(packet));
}

// ====================
// = Run-loop related =
// ====================

static void data_from_server_stub (CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, void const* data, void* info)
{
    ///TODO
//    document::server().data_from_server();
}

- (void)data_from_server
{
//    struct { NSUInteger client_id; int flags; NSString ** path; } packet;
//    ssize_t len = read(read_from_server_pipe, &packet, sizeof(packet));
//    if(len == sizeof(packet))
//    {
//        NSDictionary *it = [_clients objectFoKey: @(packet.client_id)];
//        if(it)
//        {
//            //it  ->callback(packet.flags, packet.path ? *packet.path : NULL_STR);
//        }
//    }
}

// ============================
// = Running in server thread =
// ============================

- (void)addClient: (NSUInteger)clientID
             path: (NSString *)path
{
    //D(DBF_Document_WatchFS, bug("%zu: %s\n", client_id, path.c_str()););
    OakDocumentWatchInfo *info = [[OakDocumentWatchInfo alloc] init];
    [info setPath: path];
    
    [_watchInfos setObject: info
                    forKey: @(clientID)];

    [self observeInfo: info
             clientID: clientID];
}

- (void)observeInfo: (OakDocumentWatchInfo *)info
           clientID: (NSUInteger)clinetID
{
//    info.path_watched = existing_parent(info.path);
//    info.fd = open(info.path_watched.c_str(), O_EVTONLY|O_CLOEXEC, 0);
//    if(info.fd == -1) // TODO we need to actually handle this error @allan
//        fprintf(stderr, "error observing path, open(\"%s\"): %s\n", info.path_watched.c_str(), strerror(errno));
//    
//    struct kevent changeList;
//    struct timespec timeout = { };
//    EV_SET(&changeList, info.fd, EVFILT_VNODE, EV_ADD | EV_ENABLE | EV_CLEAR, NOTE_DELETE | NOTE_WRITE | NOTE_RENAME | NOTE_ATTRIB, 0, (void*)client_id);
//    int n = kevent(event_queue, &changeList, 1 /* number of changes */, NULL /* event list */, 0 /* number of events */, &timeout);
//    if(n == -1)
//        fprintf(stderr, "error observing path, kevent(\"%s\"): %s\n", info.path_watched.c_str(), strerror(errno));
}

- (void)run
{
//    [[NSThread currentThread] setName: @"document::watch_server_t"];
//    
//    signal(SIGPIPE, SIG_IGN);
//    event_queue = kqueue();
//    
//    struct kevent changeList;
//    struct timespec timeout = { };
//    EV_SET(&changeList, read_from_master_pipe, EVFILT_READ, EV_ADD | EV_ENABLE | EV_CLEAR, 0, 0, (void*)0);
//    int n = kevent(event_queue, &changeList, 1 /* number of changes */, NULL /* event list */, 0 /* number of events */, &timeout);
//    if(n == -1)
//        perror("watch server, error monitoring pipe");
//    
//    struct kevent changed;
//    while(kevent(event_queue, NULL /* change list */, 0 /* number of changes */, &changed /* event list */, 1 /* number of events */, NULL) == 1)
//    {
//        if(changed.filter == EVFILT_READ)
//        {
//            if(changed.flags & EV_EOF) // master thread closed channel, time to quit
//                break;
//            
//            struct { NSUInteger client_id; NSString ** path; } packet;
//            ssize_t len = read(read_from_master_pipe, &packet, sizeof(packet));
//            D(DBF_Document_WatchFS, bug("%zd bytes from master\n", len););
//            if(len == sizeof(packet))
//            {
//                if(packet.path)
//                    server_add(packet.client_id, *packet.path);
//                else	server_remove(packet.client_id);
//                delete packet.path;
//            }
//        }
//        else if(changed.filter == EVFILT_VNODE)
//        {
//            NSUInteger client_id = (NSUInteger)changed.udata;
//            
//            std::map<NSUInteger, watch_info_t*>::iterator it = watch_info.find(client_id);
//            if(it != watch_info.end())
//            {
//                BOOL did_exist = it->second->path == it->second->path_watched;
//                BOOL does_exist = it->second->path == existing_parent(it->second->path);
//                
//                if(did_exist || does_exist)
//                {
//                    int flags = did_exist ? changed.fflags : NOTE_CREATE;
//                    if(does_exist && (changed.fflags & (NOTE_DELETE | NOTE_WRITE)) == NOTE_DELETE)
//                        flags ^= (NOTE_DELETE | NOTE_WRITE);
//                    
//                    if((flags & NOTE_RENAME) == NOTE_RENAME)
//                    {
//                        for(NSUInteger i = 0; i < 100; ++i)
//                        {
//                            if(path::exists(it->second->path))
//                            {
//                                flags ^= NOTE_RENAME | (~flags & NOTE_WRITE);
//                                close(it->second->fd);
//                                observe(*it->second, it->first);
//                                break;
//                            }
//                            usleep(10);
//                        }
//                    }
//                    
//                    NSString * path = (flags & NOTE_RENAME) == NOTE_RENAME ? path::for_fd(it->second->fd) : NULL_STR;
//                    struct { NSUInteger client_id; int flags; NSString ** path; } packet = { client_id, flags, path == NULL_STR ? NULL : new NSString *(path) };
//                    if(write(write_to_master_pipe, &packet, sizeof(packet)) == -1)
//                        break; // channel to master is gone, let’s quit
//                }
//                
//                if((changed.fflags & NOTE_DELETE) || it->second->path_watched != existing_parent(it->second->path))
//                {
//                    close(it->second->fd);
//                    observe(*it->second, it->first);
//                }
//            }
//        }
//    }
//    
//    close(event_queue);
//    close(write_to_master_pipe);
//    close(read_from_master_pipe);
}

@end

@implementation OakDocumentWatch


static NSString *existing_parent (NSString * path)
{
    while(![path isEqualToString: @"/"] && access([path UTF8String], F_OK) != 0)
    {
        path = [path stringByDeletingLastPathComponent];
    }
    
    return path;
}

@end

@implementation OakDocumentWatchBase

- (id)initWithPath: (NSString *)path
{
    if ((self = [super init]))
    {
        client_id = [[OakDocumentWatchServer sharedServer] addClient: path
                                                            callback: self];
    }
    
    return self;
}

- (void)dealloc
{
    [(OakDocumentWatchServer *)[OakDocumentWatchServer sharedServer] removeClient: client_id];
    
    [super dealloc];
}

- (void)callbackWithFlag: (NSInteger)flags
                    path: (NSString *)newPath
{
#ifndef NDEBUG
    static struct { int flag; char const* name; } const flagNames[] =
    {
        { NOTE_RENAME, ", rename" },
        { NOTE_WRITE,  ", write"  },
        { NOTE_DELETE, ", delete" },
        { NOTE_ATTRIB, ", attribute change" },
        { NOTE_CREATE, ", create" },
    };
#endif
    
      NSMutableString *change = [NSMutableString string];
    
      for(NSUInteger i = 0; i < sizeof(flagNames); ++i)
      {
          [change appendFormat: @"%s", (flags & flagNames[i].flag) ? flagNames[i].name : ""];
      }
    
    NSLog(@"in func: %@", change);
}

@end
