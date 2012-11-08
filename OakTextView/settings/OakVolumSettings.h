//
//  OakVolumSettings.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakVolumSettings : NSObject

- (BOOL)extendedAttributes;

+ (NSDictionary *)volumeSettings;

+ (id)settingsWithPath: (NSString *)path;

@end
