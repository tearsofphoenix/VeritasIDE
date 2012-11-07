//
//  PBXGlobalID.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXGlobalID.h"

@implementation PBXGlobalID

static BOOL s_PBXGloablIDCacheHexStrings = YES;
static NSMutableDictionary *s_PBXGlobalIDStringsCache = nil;

+ (void)initialize
{
    s_PBXGlobalIDStringsCache = [[NSMutableDictionary alloc] initWithCapacity: 64];
}

+ (void)setCachesHexStrings: (BOOL)flag
{
    if (s_PBXGloablIDCacheHexStrings != flag)
    {
        s_PBXGloablIDCacheHexStrings = flag;
        
        if (!s_PBXGloablIDCacheHexStrings)
        {
            [s_PBXGlobalIDStringsCache removeAllObjects];
        }
    }
}

@synthesize representedObject = _representedObject;


- (NSString *)description
{
    return [[self hexString] description];
}

- (NSString *)hexString
{
    return _hexString;
}

- (NSUInteger)hash
{
    return [[self hexString] hash];
}

- (BOOL)isEqual: (id)arg1
{
    return (
            [arg1 isKindOfClass: [self class]]
            && ([[arg1 hexString] isEqualToString: [self hexString]])
            && ([[arg1 representedObject] isEqual: _representedObject])
            );
}

- (id)copyWithZone: (NSZone *)zone
{
    id copy = [[[self class] allocWithZone: zone] initWithHexString: [self hexString]];
    [copy setRepresentedObject: _representedObject];
    
    return copy;
}

- (void)dealloc
{
    _representedObject = nil;
    
    [super dealloc];
}

- (id)initWithHexString: (NSString *)arg1
{
    if ((self = [super init]))
    {
        _hexString = [arg1 retain];
    }
    
    return self;
}

- (id)init
{
    return [self initWithHexString: nil];
}

- (void)_cacheHexString: (NSString *)str
{
    [s_PBXGlobalIDStringsCache setObject: str
                                  forKey: [NSValue valueWithPointer: self]];
}

- (NSString *)_cachedHexString
{
    return [s_PBXGlobalIDStringsCache objectForKey: [NSValue valueWithPointer: self]];
}

@end