//
//  PBXContainerItem.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import "PBXContainerItem.h"

@implementation PBXContainerItem

+ (NSString *)archiveNameForKey: (id)key
{
    return nil;
}

+ (id)archivableUserAttributes
{
    return nil;
}

+ (id)archivableAttributes
{
    return nil;
}

- (BOOL)shouldArchiveUserInterfaceContext
{
    return NO;
}

- (BOOL)shouldArchiveComments
{
    return YES;
}

- (void)removeObjectForUserInterfaceContextKey: (id)key
{
    [_uiContext removeObjectForKey: key];
}

- (void)         setObject: (id)value
forUserInterfaceContextKey: (id)key
{
    [_uiContext setObject: value
                   forKey: key];
}

- (id)objectForUserInterfaceContextKey: (id)key
{
    return [_uiContext objectForKey: key];
}

- (void)willChangeWithArchivePriority: (int)arg1
{
    
}

- (void)willChange
{
    
}

- (int)changeMask
{
    return 0;
}

- (void)setUserInterfaceContext: (NSDictionary *)userInterfaceContext
{
    [_uiContext setDictionary: userInterfaceContext];
}

- (NSDictionary *)userInterfaceContext
{
    return [NSDictionary dictionaryWithDictionary: _uiContext];
}

@synthesize container = _container;

@synthesize project = _project;

@synthesize comments = _comments;

- (void)dealloc
{
    [_uiContext release];
    [_comments release];
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        _uiContext = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)handleMoveCommand: (id)sender
{
    
}

@end
