//
//  VMKDebugServer.h
//
//  Copyright (c) 2012 Damian Kolakowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMKMachineService.h"

@protocol HVRequestHandler;

@interface VMKDebugServer : NSObject<VMKDebugServer>
{
    int _listenPort;
    int _listenSocket;
    BOOL _done;
    BOOL _canLauch;
    NSMutableDictionary *_handlers;
}

@property (nonatomic, assign) VMKLuaStateRef state;

+ (VMKDebugServer *)sharedServer;

- (void)registerHandler: (id<HVRequestHandler>)handler
           forURLScheme: (NSString *)url;

- (void)registerHandler: (id<HVRequestHandler>)handler
          forURLSchemes: (NSArray *)urls;

@end
