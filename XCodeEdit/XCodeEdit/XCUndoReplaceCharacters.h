/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSUndoReplaceCharacters.h"

@class XCTokenizedEditingUndoHelper;

@interface XCUndoReplaceCharacters : NSUndoReplaceCharacters
{
    XCTokenizedEditingUndoHelper *_tokenizedEditingUndoHelper;
}

- (void)undoRedo:(id)arg1;
- (id)replacementRanges;
- (id)affectedRanges;
- (void)dealloc;
- (id)initWithAffectedRange:(NSRange)arg1 layoutManager:(id)arg2 undoManager:(id)arg3 replacementRange:(NSRange)arg4;

@end
