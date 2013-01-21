/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <XcodeEdit/XCSourceScanner.h>

@class NSCharacterSet, XCSourceTokens;

@interface XCKeywordScanner : XCSourceScanner
{
    NSCharacterSet *_startSet;
    NSCharacterSet *_invertedOtherSet;
    XCSourceTokens *_keywords;
    NSRange _previousTokenRange;
    BOOL _caseSensitive;
    BOOL _isSimpleToken;
}

- (NSRange)wordRangeInString:(id)arg1 fromIndex:(NSUInteger)arg2;
- (BOOL)canTokenize;
- (id)parse:(id)arg1 withContext:(id)arg2 initialToken:(NSInteger)arg3 inputStream:(id)arg4 range:(NSRange)arg5 dirtyRange:(NSRange *)arg6;
- (NSInteger)nextToken:(id)arg1 withContext:(id)arg2 initialToken:(NSInteger)arg3;
- (BOOL)predictsRule:(NSInteger)arg1 inputStream:(id)arg2;
- (void)dealloc;
- (id)initWithPropertyListDictionary:(id)arg1 language:(NSInteger)arg2;

@end
