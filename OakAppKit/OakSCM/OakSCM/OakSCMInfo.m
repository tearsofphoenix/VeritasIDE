
#import "OakSCMDriver.h"
#import "OakSCMInfo.h"
#import "OakSCMWatcher.h"

NSString * OakStringFromSCMStatus(OakSCMStatus status)
{
    switch(status)
    {
        case OakSCMStatusUnknown:      return @"unknown";
        case OakSCMStatusNone:         return @"clean";
        case OakSCMStatusUnversioned:  return @"untracked";
        case OakSCMStatusModified:     return @"modified";
        case OakSCMStatusAdded:        return @"added";
        case OakSCMStatusDeleted:      return @"deleted";
        case OakSCMStatusConflicted:   return @"conflicted";
        case OakSCMStatusIgnored:      return @"ignored";
        case OakSCMStatusMixed:        return @"mixed";
        default:           return [NSString stringWithFormat: @"unknown (%ld)", status];
    }
}

// ==========
// = info_t =
// ==========
@implementation OakSCMInfo

- (id)initWithPath: (NSString *)path
            driver: (OakSCMDriver *)driver
{
    if ((self = [super init]))
    {
        _observedPath = [path retain];
        _driver = [driver retain];
        
        _fileStatus = [[NSMutableDictionary alloc] init];

    }
    
    return self;
}

- (void)dealloc
{
    [_observedPath release];
    [_driver release];
    
    [_fileStatus release];
    
    [super dealloc];
}

- (NSString *)SCMName
{
    return [_driver name];
}

- (NSString *)path
{
    return _observedPath;
}

- (NSString *)branchName
{
    return [_driver branchNameForPath: _observedPath];
}

- (BOOL)tracksDirectories
{
    return [_driver tracksDirectories];
}

- (void)setup
{
    if (!_didSetup)
    {
        [_fileStatus setDictionary: [_driver statusForPath: _observedPath]];
        
        ///TODO: new watcher here
        _watcher = [[OakSCMWatcher alloc] initWithPath: _observedPath];
        
        [_watcher setCallback: (^(NSString *path, OakSCMFileEvent event)
                                {
                                    NSLog(@"in func: %s\n", __func__);
                                    
                                })];

        [_watcher start];
        
        _didSetup = YES;
    }
}

- (OakSCMStatus)statusForPath: (NSString *)path
{
    [self setup];
    
    return [[_fileStatus objectForKey: path] integerValue];
}

- (NSDictionary *)filesWithStatus: (int)mask
{
    [self setup];
    
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
    [_fileStatus enumerateKeysAndObjectsUsingBlock: (^(id key, NSNumber *obj, BOOL *stop)
                                                      {
                                                          NSInteger flag = [obj integerValue];
                                                          if ((flag & mask) == flag)
                                                          {
                                                              [res setObject: obj
                                                                      forKey: key];
                                                          }
                                                      })];
    
    return res;
}

@end

