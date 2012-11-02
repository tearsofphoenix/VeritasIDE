//
//  PBXLexicalRules.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXLexicalRules.h"
#import "PBXSourceTokens.h"

@implementation PBXLexicalRules

- (BOOL)isNumber: (NSString *)arg1
       withRange: (NSRange *)arg2
{
    ///TODO:
    return NO;
}

- (NSInteger)tokenForString: (NSString *)arg1
{
    
}

- (BOOL)fortranStyleComments
{
    return _fortranStyleComments;
}

- (BOOL)commentsCanBeNested
{
    return _commentsCanBeNested;
}

- (BOOL)indexedSymbols
{
    return _indexedSymbols;
}

- (BOOL)unicodeSymbols
{
    return _unicodeSymbols;
}

- (BOOL)caseSensitive
{
    return _caseSensitive;
}

- (NSCharacterSet *)domainNameChars
{
    return _domainNameChars;
}

- (NSCharacterSet *)urlLocationChars
{
    return _urlLocationChars;
}

- (NSCharacterSet *)linkPrefixChars
{
    return _linkPrefixChars;
}

- (NSString *)mailLocalNameDelimiter
{
    return _mailLocalNameDelimiter;
}

- (NSString *)urlSchemeDelimiter
{
    return _urlSchemeDelimiter;
}

- (unichar)docCommentKeywordStart
{
    return _docCommentKeywordStart;
}

- (unichar)preprocessorKeywordStart
{
    return _preprocessorKeywordStart;
}
- (unichar)escapeCharacter
{
    return _escapeCharacter;
}

- (id)docComment
{
    return _docComment;
}

- (NSArray *)characterDelimiters
{
    return [NSArray arrayWithArray: _characterDelimiters];
}

- (NSArray *)singleLineComment
{
    return [NSArray arrayWithArray: _singleLineComment];
}

- (NSArray *)commentDelimiters
{
    return _commentDelimiters;
}
- (NSArray *)stringDelimiters
{
    return _stringDelimiters;
}

- (PBXSourceTokens *)preprocessorKeywords
{
    return _preprocessorKeywords;
}

- (PBXSourceTokens *)docCommentKeywords
{
    return _docCommentKeywords;
}

- (PBXSourceTokens *)altKeywords
{
    return _altKeywords;
}
- (PBXSourceTokens *)keywords
{
    return _keywords;
}

- (BOOL)isPreprocessorKeyword: (NSString *)arg1
{
    return [_preprocessorKeywords containsToken: arg1];
}

- (BOOL)isDocCommentKeyword: (NSString *)arg1
{
    return [_docCommentKeywords containsToken: arg1];
}

- (BOOL)isAltKeyword: (NSString *)arg1
{
    return [_altKeywords containsToken: arg1];
}

- (BOOL)isKeyword: (NSString *)arg1
{
    return [_keywords containsToken: arg1];
}

- (NSCharacterSet *)nonWhitespaceCharacterSet
{
    return _nonWhitespaceChars;
}

- (NSCharacterSet *)nonIdentifierCharacterSet
{
    return _nonIdentifierCharacters;
}

- (BOOL)isDomainNameStartChar:(unichar)arg1
{
    return [_domainNameStartChars characterIsMember: arg1];
}
- (BOOL)isLinkStartChar:(unichar)arg1
{
    return [_linkStartChars characterIsMember: arg1];
}

- (BOOL)isWhitespaceChar:(unichar)arg1
{
    return [_whitespaceChars characterIsMember: arg1];
}
- (BOOL)isEndOfLineChar:(unichar)arg1
{
    return [_endOfLineChars characterIsMember: arg1];
}
- (BOOL)isNumericChar:(unichar)arg1
{
    return [_numericChars characterIsMember: arg1];
}
- (BOOL)isNumericStartChar:(unichar)arg1
{
    return [_numericStartChars characterIsMember: arg1];
}
- (BOOL)isIdentifierChar:(unichar)arg1
{
    return [_identifierChars characterIsMember: arg1];
}
- (BOOL)isIdentifierStartChar:(unichar)arg1
{
    return [_identifierStartChars characterIsMember: arg1];
}
- (BOOL)isEndCharStartChar:(unichar)arg1
{
    return [_endCharStartChars characterIsMember: arg1];
}
- (BOOL)isCharStartChar:(unichar)arg1
{
    return [_charStartChars characterIsMember: arg1];
}
- (BOOL)isEndStringStartChar:(unichar)arg1
{
    return [_endStringStartChars characterIsMember: arg1];
}
- (BOOL)isStringStartChar:(unichar)arg1
{
    return [_stringStartChars characterIsMember: arg1];
}
- (BOOL)isSingleLineCommentStartChar:(unichar)arg1
{
    return [_singleLineCommentStartChars characterIsMember: arg1];
}
- (BOOL)isEndCommentStartChar:(unichar)arg1
{
    return [_endCommentStartChars characterIsMember: arg1];
}

- (BOOL)isCommentStartChar:(unichar)arg1
{
    return [_commentStartChars characterIsMember: arg1];
}

- (void)addDictionary:(id)arg1
{
    
}
- (id)initWithDictionary: (id)arg1
{
    if ((self = [super init]))
    {
        _commentStartChars = [[NSMutableCharacterSet alloc] init];
        _endCommentStartChars = [[NSMutableCharacterSet alloc] init];
        _singleLineCommentStartChars = [[NSMutableCharacterSet alloc] init];
        _stringStartChars = [[NSMutableCharacterSet alloc] init];
        _endStringStartChars = [[NSMutableCharacterSet alloc] init];
        _charStartChars = [[NSMutableCharacterSet alloc] init];
        _endCharStartChars = [[NSMutableCharacterSet alloc] init];
        _identifierStartChars = [[NSMutableCharacterSet alloc] init];
        _identifierChars = [[NSMutableCharacterSet alloc] init];
        
        //_nonIdentifierCharacters;

        _numericStartChars = [[NSMutableCharacterSet alloc] init];
        _numericChars = [[NSMutableCharacterSet alloc] init];
        _endOfLineChars = [[NSMutableCharacterSet alloc] init];
        
        //_whitespaceChars;
        //_nonWhitespaceChars;
        
        //_keywords;
        //_altKeywords;
        //_docCommentKeywords;
        //_preprocessorKeywords;
        
        _stringDelimiters = [[NSMutableArray alloc] init];
        _commentDelimiters = [[NSMutableArray alloc] init];
        _singleLineComment = [[NSMutableArray alloc] init];
        _characterDelimiters = [[NSMutableArray alloc] init];

        //_linkStartChars;
        //_linkPrefixChars;
        //_urlLocationChars;
        //_domainNameStartChars;
        //_domainNameChars;
    }
    
    return self;
}

- (id)init
{
    return [self initWithDictionary: nil];
}


@end