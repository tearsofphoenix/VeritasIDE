//
//  PBXSourceTokens.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXSourceTokens.h"

@implementation PBXSourceTokens


+ (NSInteger)addTokenForString: (id)str
{
    
}

+ (NSInteger)_tokenForString: (id)str
{
    
}

- (id)allTokens
{
    
}

- (NSInteger)tokenForString: (NSString *)str
{
    
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

@end
