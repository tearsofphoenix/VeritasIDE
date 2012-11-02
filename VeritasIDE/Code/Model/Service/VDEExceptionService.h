//
//  VDEExceptionService.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-2.
//
//

#import <VeritasMachineKit/VeritasMachineKit.h>

@interface VDEExceptionService : VMetaService

@end

extern NSString * VDEExceptionServiceID;

extern NSString * VDEExceptionServiceHandleErrorInFunctionAction;

#define VDEExceptionServiceHandleError(error) do{ if((error)) VSC(VDEExceptionServiceID, VDEExceptionServiceHandleErrorInFunctionAction, nil, @[(error), [NSString stringWithUTF8String: __func__]]);}while(0)