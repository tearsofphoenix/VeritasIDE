//
//  PBXObject.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXObject.h"
#import "PBXGlobalID.h"
#import "NSString+RandomHexString.h"

@implementation PBXObject

static BOOL s_PBXObjectChangeNotificationsEnabled = YES;
static NSMutableDictionary *s_PBXObjectFallbackClassNames = nil;

+ (NSString *)longDescription
{
    return NSStringFromClass(self);
}

+ (NSString *)innerLongDescriptionWithIndentLevel:(NSUInteger)arg1
{
    return NSStringFromClass(self);
}

+ (NSString *)description
{
    return NSStringFromClass(self);
}

+ (NSString *)innerDescription
{
    return NSStringFromClass(self);
}

+ (void)setChangeNotificationsEnabled: (BOOL)flag
{
    if (s_PBXObjectChangeNotificationsEnabled != flag)
    {
        s_PBXObjectChangeNotificationsEnabled = flag;
    }
}

+ (BOOL)changeNotificationsEnabled
{
    return s_PBXObjectChangeNotificationsEnabled;
}

+ (BOOL)hasUserKeys
{
    return NO;
}

+ (void)_clearFallbackClassNameCache: (id)arg1
{
    [s_PBXObjectFallbackClassNames removeAllObjects];
}

+ (NSString *)_classNameToFallbackClassNameDict
{
    return nil;
}

- (NSString *)longDescription
{
    return [NSString stringWithFormat: @"<%@, globalID: %@", [self description], _globalID];
}

- (NSString *)innerLongDescriptionWithIndentLevel:(NSUInteger)arg1
{
    return [self longDescription];
}

- (NSString *)description
{
    return [super description];
}

- (NSString *)innerDescription
{
    return [self description];
}

- (void)willChange
{
    
}

- (PBXGlobalID *)globalID
{
    return [self globalIDCreateIfNeeded: YES];
}

- (PBXGlobalID *)globalIDCreateIfNeeded: (BOOL)needed
{
    
    if (needed && !_globalID)
    {
        _globalID = [[PBXGlobalID alloc] initWithHexString: [NSString randomHexString]];
    }
    
    return _globalID;
}

- (void)dealloc
{
    [_globalID release];
    
    [super dealloc];
}

- (id)copyWithZone: (NSZone *)zone
{
    id copy = [[[self class] allocWithZone: zone] init];
    
    return copy;
}

- (id)init
{
    if ((self = [super init]))
    {

    }
    
    return self;
}

@end