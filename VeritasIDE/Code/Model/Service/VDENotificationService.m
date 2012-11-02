//
//  VDENotificationService.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-28.
//
//

#import "VDENotificationService.h"


static  NSNotificationCenter *_notificationCenter = nil;

@implementation VDENotificationService

+ (id)identity
{
    return VDENotificationServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (id)init
{
    if ((self = [super init]))
    {
        _notificationCenter = [[NSNotificationCenter alloc] init];
        
    }
    
    return self;
}

- (void)dealloc
{
    [_notificationCenter release];
    
    [super dealloc];
}

+ (NSNotificationCenter *)serviceCenter
{
    return _notificationCenter;
}

@end

NSString * const VDENotificationServiceID = @"com.veritas.ide.service.notification";
