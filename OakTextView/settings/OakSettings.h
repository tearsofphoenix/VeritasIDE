//
//  OakSettings.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakSettings : NSObject
{
	NSMutableDictionary *_settings;
}

- (id)initWithDictionary: (NSDictionary *)dict;

- (BOOL)hasValueForKey: (NSString *)key;

- (id)settingForKey: (NSString *)key;

- (NSDictionary *)allSettings;

@end
