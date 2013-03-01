//
//  VMKDebugCommandLaunchHandler.m
//  VeritasMachineKit
//
//  Created by tearsofphoenix on 13-3-1.
//
//

#import "VMKDebugCommandLaunchHandler.h"

@implementation VMKDebugCommandLaunchHandler

- (BOOL)handleRequest: (NSString *)url
          withHeaders: (NSDictionary *)headers
                query: (NSDictionary *)query
              address: (NSString *)address
             onSocket: (int)socket
{
    if ([super handleRequest: url
                 withHeaders: headers
                       query: query
                     address: address
                    onSocket: socket])
    {
        if ([self writeText: @"\r\n"
                   toSocket: socket])
        {
            return [self writeText: [NSString stringWithFormat: @"Lua state: %p waiting for lauch...", _state]
                          toSocket: socket];
        }
    }
    
    return NO;
}

@end
