//
//  VDENotificationService.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-28.
//
//

#import <VeritasMachineKit/VeritasMachineKit.h>

@interface VDENotificationService : VMetaService

+ (NSNotificationCenter *)serviceCenter;

@end

extern NSString * const VDENotificationServiceID;
