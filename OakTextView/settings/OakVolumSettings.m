//
//  OakVolumSettings.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakVolumSettings.h"

@interface OakVolumSettings()
{
    BOOL _extendedAttributes;
    BOOL _scmBadges;
    BOOL _displayNames;
}
@end

@implementation OakVolumSettings

- (id)init
{
    if ((self = [super init]))
    {
        _extendedAttributes = YES;
        _scmBadges = YES;
        _displayNames = YES;
    }
    return self;
}

- (BOOL)extendedAttributes
{
    return _extendedAttributes;
}
    
+ (NSDictionary *)volumeSettings
{
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
//    CFPropertyListRef cfPlist = CFPreferencesCopyAppValue(CFSTR("volumeSettings"), kCFPreferencesCurrentApplication);
//    if(cfPlist)
//    {
//        citerate(pair, plist::convert(cfPlist))
//        {
//            settings_t info;
//            plist::get_key_path(pair->second, "extendedAttributes", info._extended_attributes);
//            plist::get_key_path(pair->second, "scmBadges",          info._scm_badges);
//            plist::get_key_path(pair->second, "displayNames",       info._display_names);
//            res.insert(std::make_pair(pair->first, info));
//        }
//        CFRelease(cfPlist);
//    }
    
    return res;
}

+ (id)settingsWithPath: (NSString *)path
{
//    static NSMutableDictionary *userSettings = [self volumeSettings];
//    iterate(pair, userSettings)
//    {
//        if(path.find(pair->first) == 0)
//            return pair->second;
//    }
//    
//    static volume::settings_t defaultSettings;
//    return defaultSettings;
    return nil;
}

@end
