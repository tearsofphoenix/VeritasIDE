/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@class PBXProjectIndex;

@interface PBXIndexEntry : NSObject
{
    PBXProjectIndex *_projectIndex;
    union _pbxsymbollocation _location;
    NSString *_sourceFile;
}

- (id)sourceFile;
- (NSUInteger)lineNumber;
- (unsigned int)rawLocation;
- (union _pbxsymbollocation)location;
- (id)project;
- (id)projectIndex;
- (BOOL)isEqual:(id)arg1;
- (NSUInteger)hash;
- (void)dealloc;
- (id)initWithProjectIndex:(id)arg1 location:(union _pbxsymbollocation)arg2;

@end

