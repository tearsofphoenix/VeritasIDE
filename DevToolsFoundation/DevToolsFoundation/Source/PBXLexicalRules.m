//
//  PBXLexicalRules.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXLexicalRules.h"
#import "PBXSourceTokens.h"

NSString * const PBXLexicalRuleCommentStartKey = @"commentStart";
NSString * const PBXLexicalRuleEndCommentStartKey = @"endCommentStart";
NSString * const PBXLexicalRuleSingleLineCommentStartKey = @"singleLineCommentStart";

NSString * const PBXLexicalRuleStringStartKey = @"stringStart";
NSString * const PBXLexicalRuleEndStringStartKey = @"endStringStart";

NSString * const PBXLexicalRuleCharStartKey = @"charStart";
NSString * const PBXLexicalRuleEndCharStartKey = @"endCharStart";

NSString * const PBXLexicalRuleIdentifierStartKey = @"identifierStart";
NSString * const PBXLexicalRuleIdentifierKey = @"identifier";

NSString * const PBXLexicalRuleNumericStartKey = @"numericStart";
NSString * const PBXLexicalRuleNumericKey = @"numeric";

NSString * const PBXLexicalRuleEndOfLineKey = @"endOfLine";

NSString * const PBXLexicalRuleWhitespaceKey = @"whiteSpace";
NSString * const PBXLexicalRuleKeywordsKey = @"keywords";
NSString * const PBXLexicalRuleAltKeywordsKey = @"altKeywords";

NSString * const PBXLexicalRuleDocCommentKeywordsKey = @"docComment";

NSString * const PBXLexicalRulePreprocessorKeywordsKey = @"preprocessorKeywords";

NSString * const PBXLexicalRuleStringDelimitersKey = @"stringDelimiters";

NSString * const PBXLexicalRuleCommentDelimitersKey = @"commentDelimiters";

NSString * const PBXLexicalRuleSingleLineCommentKey = @"singleLineComment";

NSString * const PBXLexicalRuleCharacterDelimitersKey = @"characterDelimiters";

NSString * const PBXLexicalRuleLinkStartKey = @"linkStart";
NSString * const PBXLexicalRuleLinkPrefixKey = @"linkPrefix";
NSString * const PBXLexicalRuleURLLocationKey = @"URLLocation";
NSString * const PBXLexicalRuleDomainNameStartKey = @"domainNameStart";
NSString * const PBXLexicalRuleDomainNameKey = @"domainName";
NSString * const PBXLexicalRuleURLSchemeDelimiterKey = @"URLSchemeDelimiter";
NSString * const PBXLexicalRuleMailLocalNameDelimiterKey = @"mailLocalNameDelimiter";

@implementation PBXLexicalRules

- (BOOL)isNumber: (NSString *)arg1
       withRange: (NSRange *)arg2
{
    ///TODO:
    return NO;
}

- (PBXTokenType)tokenForString: (NSString *)arg1
{
    PBXTokenType tokenType = PBXInvalidToken;
    tokenType = [_keywords tokenForString: arg1];
    if (tokenType != PBXInvalidToken)
    {
        return tokenType;
    }
    
    tokenType = [_altKeywords tokenForString: arg1];

    if(tokenType != PBXInvalidToken)
    {
        return tokenType;
    }

    return tokenType;
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

- (void)addDictionary: (NSDictionary *)dict
{
    [_commentStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleCommentStartKey]];
    [_endCommentStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleEndCommentStartKey]];
    [_singleLineCommentStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleSingleLineCommentStartKey]];
    [_stringStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleStringStartKey]];
    [_endStringStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleEndStringStartKey]];
    [_charStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleCharStartKey]];
    [_endCharStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleEndCharStartKey]];
    [_identifierStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleIdentifierStartKey]];
    [_identifierChars addCharactersInString: [dict objectForKey: PBXLexicalRuleIdentifierKey]];
    
    [_nonIdentifierCharacters release];
    _nonIdentifierCharacters = [[_identifierChars invertedSet] retain];
    
    [_numericStartChars addCharactersInString: [dict objectForKey: PBXLexicalRuleNumericStartKey]];
    [_numericChars addCharactersInString: [dict objectForKey: PBXLexicalRuleNumericKey]];
    [_endOfLineChars addCharactersInString: [dict objectForKey: PBXLexicalRuleEndOfLineKey]];
    
    [_whitespaceChars release];
    _whitespaceChars = [[NSCharacterSet characterSetWithCharactersInString: [dict objectForKey: PBXLexicalRuleWhitespaceKey]] retain];
    
    [_nonWhitespaceChars release];
    _nonWhitespaceChars = [[_whitespaceChars invertedSet] retain];
    
    [_keywords addArrayOfStrings: [dict objectForKey: PBXLexicalRuleKeywordsKey]];
    
    [_altKeywords addArrayOfStrings: [dict objectForKey: PBXLexicalRuleAltKeywordsKey]];
    [_docCommentKeywords addArrayOfStrings: [dict objectForKey: PBXLexicalRuleDocCommentKeywordsKey]];
    [_preprocessorKeywords addArrayOfStrings: [dict objectForKey: PBXLexicalRulePreprocessorKeywordsKey]];

}
- (id)initWithDictionary: (NSDictionary *)dict
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
        
        //_nonIdentifierCharacters = nil;
        
        _numericStartChars = [[NSMutableCharacterSet alloc] init];
        _numericChars = [[NSMutableCharacterSet alloc] init];
        _endOfLineChars = [[NSMutableCharacterSet alloc] init];
        
        //_whitespaceChars = [[NSCharacterSet alloc] init];
        //_nonWhitespaceChars = nil;
        
        _keywords = [[PBXSourceTokens alloc] init];
        _altKeywords = [[PBXSourceTokens alloc] init];
        _docCommentKeywords = [[PBXSourceTokens alloc] init];
        _preprocessorKeywords = [[PBXSourceTokens alloc] init];

        [self addDictionary: dict];
        
        _docComment = nil;
        _docCommentKeywordStart = 0;
        _preprocessorKeywordStart = '#';
        _escapeCharacter = '\\';
        
        //NSCharacterSet *_linkStartChars;
        //NSCharacterSet *_linkPrefixChars;
        //NSCharacterSet *_urlLocationChars;
        //NSCharacterSet *_domainNameStartChars;
        //NSCharacterSet *_domainNameChars;
        //NSString *_urlSchemeDelimiter;
        //NSString *_mailLocalNameDelimiter;
        
        _caseSensitive = YES;
        _unicodeSymbols = YES;
        _indexedSymbols = YES;
        _commentsCanBeNested = NO;

    }
    
    return self;
}

- (id)init
{
    return [self initWithDictionary: nil];
}


@end