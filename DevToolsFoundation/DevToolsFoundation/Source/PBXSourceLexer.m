//
//  PBXSourceLexer.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXSourceLexer.h"
#import "PBXLexicalRules.h"

@implementation PBXSourceLexer

- (void)skipToEndDelimeter: (unichar)delimeter
                 withStart: (unichar)start
{
    CFStringRef tokenString = (CFStringRef)_tokenString;
    
    CFIndex tokenLength = CFStringGetLength(tokenString);
    
    unichar charLooper;
    
    CFIndex iLooper = 0;
    
    CFIndex indexOfStartChar = NSNotFound;
    CFIndex indexOfDelimeter = NSNotFound;
    
    while (iLooper < tokenLength)
    {
        charLooper = CFStringGetCharacterAtIndex(tokenString, iLooper);

        if (charLooper == start
            && NSNotFound == indexOfStartChar)
        {
            indexOfStartChar = iLooper;
            
        }else if (charLooper == delimeter
                  && NSNotFound == indexOfDelimeter)
        {
            indexOfDelimeter = iLooper;
        }
        
        //found both
        //
        if (NSNotFound != indexOfDelimeter
            && NSNotFound != indexOfStartChar)
        {
            break;
        }
        
        ++iLooper;
    }
    
    _tokenRange.location = indexOfStartChar;
    _tokenRange.length = indexOfDelimeter - indexOfStartChar;
}

- (BOOL)inputIsInSet: (NSSet *)arg1
{
    
}
- (BOOL)inputMatchesString:(NSString *)arg1
{
    
}
- (void)skipToEndOfLineWithEscape:(BOOL)arg1
{
    
}
- (void)skipToString: (NSString *)arg1
          withEscape: (BOOL)arg2
{

}

- (void)skipToCharacter: (unichar)arg1
             withEscape: (BOOL)arg2
{
    
}

- (unichar)skipToCharacter: (unichar)arg1
               orCharacter: (unichar)arg2
                withEscape: (BOOL)arg3
{
    
}

- (NSRange)tokenRange
{
    return _tokenRange;
}

- (NSString *)stringForRange: (NSRange)arg1
{
    return [_tokenString substringWithRange: arg1];
}

- (void)setTokenStringToRange: (NSRange)arg1
{
    _tokenRange = arg1;
}

- (NSString *)tokenString
{
    return _tokenString;
}

- (NSInteger)peekToken
{

}

- (NSInteger)cachedTokenTypeAtLocation: (NSUInteger)arg1
                            tokenRange: (NSRange *)arg2
{
    
}

- (void)stringWasEdited: (NSRange *)arg1
      replacementLength: (NSInteger)arg2
{
    
}

- (NSInteger)nextToken:(BOOL)arg1
{
    
}

- (NSInteger)nextToken
{
    
}

- (NSInteger)_nextToken
{
    
}
- (void)buildCharacterMap
{
    
}
- (void)skipMultiLineCommentFromLoc: (NSUInteger)arg1
                         matchIndex: (NSInteger)arg2
{
    
}
- (void)scanForLinksInRange:(NSRange)arg1
{
    
}
- (void)parseDocCommentFromLoc: (NSUInteger)arg1
                    matchIndex: (NSInteger)arg2
{
    
}
- (NSUInteger)_matchInArray: (id)arg1
                    atIndex: (NSInteger)arg2
{
    
}
- (NSInteger)_matchIn2DArray: (id)arg1
                     atIndex: (NSInteger)arg2
{
    
}

#pragma mark - token range

- (NSUInteger)length
{
    return _tokenRange.length;
}

- (void)decLocation
{
    _tokenRange.location -= 1;
}

- (void)incLocation
{
    _tokenRange.location += 1;
}

- (void)setLocation: (NSUInteger)arg1
{
    _tokenRange.location = arg1;
}

- (NSUInteger)curLocation
{
    return _tokenRange.location;
}

- (NSUInteger)peekCharacterInSet:(id)arg1
{
    
}

- (unichar)peekCharWithoutSkippingWhitespace
{
    unichar c = [self nextCharWithoutSkippingWhitespace];
    
    _tokenRange.location += 1;
    
    return c;
}

- (unichar)peekChar
{
    unichar c = [self nextChar];
    
    _tokenRange.location += 1;
    
    return c;
}

- (unichar)nextChar
{
    [self skipWhitespace];
    
    return [self nextCharWithoutSkippingWhitespace];
}

- (unichar)nextCharWithoutSkippingWhitespace
{
    CFStringRef tokenString = (CFStringRef)_tokenString;
    
    return CFStringGetCharacterAtIndex(tokenString, NSMaxRange(_tokenRange) + 1);
}

- (void)skipWhitespace
{
    CFStringRef tokenString = (CFStringRef)_tokenString;
    
    CFIndex tokenLength = CFStringGetLength(tokenString);
    
    CFIndex iLooper = NSMaxRange(_tokenRange);
    
    unichar charLooper = CFStringGetCharacterAtIndex(tokenString, iLooper);
    
    while ([_rules isWhitespaceChar: charLooper]
           && iLooper < tokenLength)
    {
        charLooper = CFStringGetCharacterAtIndex(tokenString, iLooper);
        ++iLooper;
    }
    
    _tokenRange.location = iLooper;
    _tokenRange.length = 0;
}

- (void)setIgnoreNewLines:(BOOL)arg1
{
    if (_ignoreNewLines != arg1)
    {
        _ignoreNewLines = arg1;
    }
}

- (PBXLexicalRules *)rules
{
    return _rules;
}

- (void)scanSubRange: (NSRange)arg1
     startingInState: (int)arg2
{
    
}
- (void)setString: (NSString *)str
            range: (NSRange)range
{
    if (_tokenString != str)
    {
        [_tokenString release];
        _tokenString = [str retain];
    
        _tokenRange = range;
    }
}

- (void)setDelegate: (id<PBXSourceLexerDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
    }
}

- (void)dealloc
{
    [_rules release];
    
    [super dealloc];
}

- (id)initWithLexicalRules: (PBXLexicalRules *)rules
{
    if ((self = [super init]))
    {
        _rules = [rules retain];
    }
    
    return self;
}

#pragma mark - delegate

- (void)gotMailAddressForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotURLForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotPreprocessorForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotIdentifierForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotAltKeywordForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotKeywordForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotDocCommentKeywordForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotDocCommentForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotMultilineCommentForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotCommentForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotNumberForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotStringForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

- (void)gotCharacterForRange:(NSRange)arg1
{
    [_delegate gotSyntaxClass: nil
                     forRange: arg1];
}

@end