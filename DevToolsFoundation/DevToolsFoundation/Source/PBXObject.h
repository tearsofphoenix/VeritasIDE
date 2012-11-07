/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <Foundation/Foundation.h>

@class PBXGlobalID;

@interface PBXObject : NSObject
{
    PBXGlobalID *_globalID;
}

+ (NSString *)longDescription;
+ (NSString *)innerLongDescriptionWithIndentLevel:(NSUInteger)arg1;
+ (NSString *)description;
+ (NSString *)innerDescription;

+ (void)setChangeNotificationsEnabled:(BOOL)flag;
+ (BOOL)changeNotificationsEnabled;

+ (BOOL)hasUserKeys;

+ (void)_clearFallbackClassNameCache: (id)arg1;
+ (NSString *)_classNameToFallbackClassNameDict;

- (NSString *)longDescription;
- (NSString *)innerLongDescriptionWithIndentLevel:(NSUInteger)arg1;
- (NSString *)description;
- (NSString *)innerDescription;

- (void)willChange;

- (PBXGlobalID *)globalID;
- (PBXGlobalID *)globalIDCreateIfNeeded: (BOOL)needed;

@end
