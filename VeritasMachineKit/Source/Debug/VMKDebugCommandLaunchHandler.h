//
//  VMKDebugCommandLaunchHandler.h
//  VeritasMachineKit
//
//  Created by tearsofphoenix on 13-3-1.
//
//

#import "HVBase64StaticFile.h"

struct lua_State;

@interface VMKDebugCommandLaunchHandler : HVBase64StaticFile

@property (nonatomic, assign) struct lua_State *state;

@end
