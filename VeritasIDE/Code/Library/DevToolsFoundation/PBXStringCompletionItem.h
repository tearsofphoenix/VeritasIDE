/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSObject.h"

#import "PBXCompletionItem-Protocol.h"

@class NSImage, NSString;

@interface PBXStringCompletionItem : NSObject <PBXCompletionItem>
{
    NSString *_name;
    NSString *_localizedName;
    NSInteger _priority;
    NSImage *_icon;
}

- (void)setPriority:(NSInteger)arg1;
- (NSInteger)priority;
- (void)setLocalizedName:(id)arg1;
- (id)localizedName;
- (void)setIcon:(id)arg1;
- (id)icon;
- (id)description;
- (id)descriptionText;
- (id)completionText;
- (id)displayType;
- (id)displayText;
- (id)name;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)arg1;
- (void)dealloc;
- (id)initWithString:(id)arg1;

@end

