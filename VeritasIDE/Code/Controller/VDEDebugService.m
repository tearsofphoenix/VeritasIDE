//
//  VDEDebugService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "VDEDebugService.h"
#import "VDEProjectConfiguration.h"
#import "VXDictObject.h"
#import "VXFileReference.h"

@implementation VDEDebugService

+ (id)identity
{
    return VDEDebugServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (void)initProcessors
{
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              VDEProjectConfiguration *projectConfiguration = [arguments objectAtIndex: 0];
                              BOOL stop = NO;
                              VXGroup *mainGroup = [projectConfiguration mainGroup];
                              [mainGroup enumerateChildrenUsingBlock: (^(id obj, BOOL *shouldStop)
                                                                       {
                                                                           if ([obj isKindOfClass: [VXFileReference class]])
                                                                           {
                                                                               
                                                                           }
                                                                       })
                                                            recusive: YES
                                                                stop: &stop];
                          })
              forAction: VDEDebugServiceBeginDebugSessionAction];
}

@end

NSString * const VDEDebugServiceID = @"com.veritas.ide.service.debug";

NSString * const VDEDebugServiceBeginDebugSessionAction = @"action.beginDebugSession";
