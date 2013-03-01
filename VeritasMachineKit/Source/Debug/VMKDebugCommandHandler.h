//
//  VMKDebugCommandHandler.h
//  VeritasMachineKit
//
//  Created by tearsofphoenix on 13-2-28.
//
//

#import "VMKDebugRequestHandler.h"

struct lua_State;

#define VMKDebugCommandLaunch           @"run"
#define VMKDebugCommandBackTrace        @"backtrace"
#define VMKDebugCommandBreakpointSet    @"breakpoint-set"
#define VMKDebugCommandBreakpointDelete @"breakpoint-delete"
#define VMKDebugCommandBreakpointList   @"breakpoint-list"

#define VMKDebugCommandExecutionStep    @"step"
#define VMKDebugCommandExecutionOver    @"over"
#define VMKDebugCommandExecutionFinish  @"finish"

@class VMKDebugCommandHandler;

typedef NSString *(* VMKDebugCommandProcessor)(VMKDebugCommandHandler *handler, NSString *command, NSDictionary *arguments);

@protocol VMKDebugCommandHandlerDelegate <NSObject>

- (void)commandHandler: (VMKDebugCommandHandler *)handler
    didReceivedCommand: (NSString *)command
             arguments: (NSDictionary *)arguments;

@end

@interface VMKDebugCommandHandler : VMKDebugRequestHandler
{
    CFMutableDictionaryRef _supportedCommands;
    
    //
    CFMutableDictionaryRef _breakpointHandlers;
    
    //interactive command support
    //
    NSMutableArray *_userCommandQueue;
    NSInteger _executionLevel;
    
    //for communication
    //
    int _socket;
}

@property (nonatomic, assign) struct lua_State *state;
@property (nonatomic, assign) id<VMKDebugCommandHandlerDelegate> delegate;

- (void)registerProcessor: (VMKDebugCommandProcessor)processor
           forCommandName: (NSString *)comamndName;

@end
