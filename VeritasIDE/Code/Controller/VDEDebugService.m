//
//  VDEDebugService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "VDEServices.h"
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
                              
                              NSMutableArray *sourceCodes = [[NSMutableArray alloc] init];
                              
                              for (id objLooper in [projectConfiguration objects])
                              {
                                  
                                  NSError *error = nil;
                                  
                                  if ([objLooper isKindOfClass: [VXFileReference class]])
                                  {
                                      NSString *fileContent = [NSString stringWithContentsOfFile: [objLooper absolutePath]
                                                                                        encoding: NSUTF8StringEncoding
                                                                                           error: &error];
                                      if (error)
                                      {
                                          VDEExceptionServiceHandleError(error);
                                          return ;
                                      }else
                                      {
                                          [sourceCodes addObject: fileContent];
                                      }
                                  }
                              };
                              
                              VSC(VMachineServiceID, VMachineServiceDebugSourceFilesAction,
                                  (^(NSArray *debugArgument)
                                   {
                                       
                                   }), @[ sourceCodes ]);
                              
                              [sourceCodes release];
                          })
              forAction: VDEDebugServiceBeginDebugSessionAction];
}

@end

NSString * const VDEDebugServiceID = @"com.veritas.ide.service.debug";

NSString * const VDEDebugServiceBeginDebugSessionAction = @"action.beginDebugSession";
