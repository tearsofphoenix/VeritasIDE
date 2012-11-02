/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <Foundation/Foundation.h>

@protocol PBXSourceLexerDelegate

- (void)gotSyntaxClass: (id)class
              forRange: (NSRange)range;
@end

@class PBXLexicalRules, XCAttributeRun;

@interface PBXSourceLexer : NSObject
{
    PBXLexicalRules *_rules;
    NSRange _tokenRange;
    NSString *_tokenString;
    id <PBXSourceLexerDelegate> _delegate;
    BOOL _ignoreNewLines;
    BOOL fortranStyleComments;
    NSMutableData *characterMapData;
    char *characterMap;
    XCAttributeRun *_tokenRun;
}

- (void)skipToEndDelimeter: (unichar)arg1
                 withStart: (unichar)arg2;

- (BOOL)inputIsInSet:(id)arg1;
- (BOOL)inputMatchesString:(id)arg1;
- (void)skipToEndOfLineWithEscape:(BOOL)arg1;

- (void)skipToString: (id)arg1
          withEscape: (BOOL)arg2;
- (void)skipToCharacter: (unichar)arg1
             withEscape: (BOOL)arg2;

- (unichar)skipToCharacter: (unichar)arg1
               orCharacter: (unichar)arg2
                withEscape: (BOOL)arg3;

- (NSRange)tokenRange;
- (id)stringForRange:(NSRange)arg1;
- (void)setTokenStringToRange:(NSRange)arg1;
- (id)tokenString;
- (NSInteger)peekToken;

- (NSInteger)cachedTokenTypeAtLocation: (NSUInteger)arg1
                            tokenRange: (NSRange *)arg2;

- (void)stringWasEdited: (NSRange *)arg1
      replacementLength: (NSInteger)arg2;

- (NSInteger)nextToken: (BOOL)arg1;
- (NSInteger)nextToken;
- (NSInteger)_nextToken;
- (void)buildCharacterMap;

- (void)skipMultiLineCommentFromLoc: (NSUInteger)arg1
                         matchIndex: (NSInteger)arg2;

- (void)scanForLinksInRange:(NSRange)arg1;

- (void)parseDocCommentFromLoc: (NSUInteger)arg1
                    matchIndex: (NSInteger)arg2;

- (NSUInteger)_matchInArray: (id)arg1
                    atIndex: (NSInteger)arg2;
- (NSInteger)_matchIn2DArray: (id)arg1
                     atIndex: (NSInteger)arg2;

- (NSUInteger)length;

- (void)decLocation;
- (void)incLocation;
- (void)setLocation:(NSUInteger)arg1;

- (NSUInteger)curLocation;
- (NSUInteger)peekCharacterInSet:(id)arg1;

- (unichar)peekCharWithoutSkippingWhitespace;
- (unichar)peekChar;
- (unichar)nextChar;
- (unichar)nextCharWithoutSkippingWhitespace;

- (void)skipWhitespace;

- (void)setIgnoreNewLines: (BOOL)arg1;

- (PBXLexicalRules *)rules;

- (void)scanSubRange: (NSRange)arg1
     startingInState: (int)arg2;

- (void)setString: (id)arg1
            range: (NSRange)arg2;

- (void)setDelegate: (id<PBXSourceLexerDelegate>)delegate;


- (id)initWithLexicalRules: (PBXLexicalRules *)rules;


- (void)gotMailAddressForRange:(NSRange)arg1;
- (void)gotURLForRange:(NSRange)arg1;
- (void)gotPreprocessorForRange:(NSRange)arg1;
- (void)gotIdentifierForRange:(NSRange)arg1;
- (void)gotAltKeywordForRange:(NSRange)arg1;
- (void)gotKeywordForRange:(NSRange)arg1;
- (void)gotDocCommentKeywordForRange:(NSRange)arg1;
- (void)gotDocCommentForRange:(NSRange)arg1;
- (void)gotMultilineCommentForRange:(NSRange)arg1;
- (void)gotCommentForRange:(NSRange)arg1;
- (void)gotNumberForRange:(NSRange)arg1;
- (void)gotStringForRange:(NSRange)arg1;
- (void)gotCharacterForRange:(NSRange)arg1;

@end

