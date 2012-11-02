/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSObject.h"

@class NSMutableArray, NSString;

@interface PBXFileTypePart : NSObject
{
    NSString *_identifier;
    PBXFileTypePart *_superpart;
    NSMutableArray *_subparts;
}

+ (id)fileTypePartFromSpecificationArray:(id)arg1 identifier:(id)arg2;
- (BOOL)isSymbolicLink;
- (BOOL)isFolder;
- (BOOL)isPlainFile;
- (id)subparts;
- (void)setSuperpart:(id)arg1;
- (id)superpart;
- (id)identifier;
- (void)dealloc;
- (id)init;
- (id)initFromSpecificationArray:(id)arg1 identifier:(id)arg2;

@end

