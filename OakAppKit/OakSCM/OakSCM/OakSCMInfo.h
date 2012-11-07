
enum
{
    OakSCMStatusUnknown     = 0,   // We should always know the state of a file so this should never happen
    OakSCMStatusNone        = 1,   // File is known and clean
    OakSCMStatusUnversioned = 2,   // File is not tracked by the version control system nor ignored
    OakSCMStatusModified    = 4,   // File has local changes
    OakSCMStatusAdded       = 8,   // File is locally marked for tracking
    OakSCMStatusDeleted     = 16,  // File is locally marked for deletion
    OakSCMStatusConflicted  = 32,  // File has conflicts that the user should resolve
    OakSCMStatusIgnored     = 64,  // File is being ignored by the version control system
    OakSCMStatusMixed       = 128, // Directory contains files with mixed state
};

typedef NSInteger OakSCMStatus;

extern NSString * OakStringFromSCMStatus(OakSCMStatus status);


@class OakSCMDriver;
@class OakSCMWatcher;
@class OakFileSystemSnapshot;

@interface OakSCMInfo : NSObject
{
    BOOL _didSetup;
    
    NSString * _observedPath;
    OakSCMDriver* _driver;
    NSMutableDictionary *_fileStatus;
    NSDate *_updated;
    OakFileSystemSnapshot *_snapshot;
    
    OakSCMWatcher *_watcher;
    NSMutableArray *_callbacks;

}

- (id)initWithPath: (NSString *)path
            driver: (OakSCMDriver *)driver;

- (NSString *)SCMName;

- (NSString *)path;

- (NSString *)branchName;

- (BOOL)tracksDirectories;

- (OakSCMStatus)statusForPath: (NSString *)path;

- (NSDictionary *)filesWithStatus: (int)mask;

@end
