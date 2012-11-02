//
//  NSMenu+VDEProjectConfigurationExtension.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-29.
//
//

#import <Cocoa/Cocoa.h>

@class VDEProjectConfiguration;

@interface NSMenu (VDEProjectConfigurationExtension)

- (void)buildMenuItemWithConfiguration: (VDEProjectConfiguration *)configuration;

@end
