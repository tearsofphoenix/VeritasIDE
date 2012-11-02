//
//  VDEExceptionService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-2.
//
//

#import "VDEExceptionService.h"

@implementation VDEExceptionService

+ (id)identity
{
    return VDEExceptionServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (void)initProcessors
{
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              NSError *error = [arguments objectAtIndex: 0];
                              NSString *functionName = nil;
                              
                              if ([arguments count] > 1)
                              {
                                  functionName = [arguments objectAtIndex: 1];
                              }
                              
                              NSLog(@"in func: %@ error: %@", functionName, error);
                              
                          })
              forAction: VDEExceptionServiceHandleErrorInFunctionAction];
}

@end



NSString * VDEExceptionServiceID = @"com.veritas.ide.service.exception";

NSString * VDEExceptionServiceHandleErrorInFunctionAction = @"action.handleErrorInFunction";

