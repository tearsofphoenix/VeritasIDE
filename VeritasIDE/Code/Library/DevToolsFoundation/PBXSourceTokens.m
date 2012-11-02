//
//  PBXSourceTokens.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXSourceTokens.h"

@implementation PBXSourceTokens

+ (PBXTokenType)addTokenForString: (NSString *)str
{
    return PBXInvalidToken;
}

+ (PBXTokenType)_tokenForString: (NSString *)str
{
    return PBXInvalidToken;
}

- (NSSet *)allTokens
{
    return _tokens;
}

- (PBXTokenType)tokenForString: (NSString *)str
{
    return PBXInvalidToken;
}

- (BOOL)containsToken: (NSString *)token
{
    if (_caseSensitive)
    {
        return [_tokens containsObject: token];
    }else
    {
        for (NSString *strLooper in _tokens)
        {
            if ([token compare: strLooper
                       options: NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                return YES;
            }
        }
        
        return NO;
    }
}

- (void)addArrayOfStrings: (NSArray *)stringArray
{
    [_tokens addObjectsFromArray: stringArray];
}

- (id)initWithArrayOfStrings: (NSArray *)stringArray
               caseSensitive: (BOOL)flag
{
    if ((self= [super init]))
    {
        _tokens = [[NSMutableSet alloc] initWithArray: stringArray];
        _caseSensitive = flag;
    }
    
    return self;
}

- (id)init
{
    return [self initWithArrayOfStrings: nil
                          caseSensitive: YES];
}

@end
