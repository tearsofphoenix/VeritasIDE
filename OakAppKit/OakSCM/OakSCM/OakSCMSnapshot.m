
#import "OakSCMSnapshot.h"

@implementation OakFileSystemSnapshotNode

- (NSArray *)entries
{
    return _entries;
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return ([_name isEqualToString: [object name]])
        && (_type == [(OakFileSystemSnapshotNode *)object type])
        && ([_modified isEqualToDate: [object modified]])
        && ([_entries  isEqualToArray: [object entries]]);
    }
    
    return NO;
}

@end


@implementation OakFileSystemSnapshot

static OakFileSystemSnapshotNode *_OakFileSystemSnapshotCollect(NSString * dir)
{
    OakFileSystemSnapshotNode *res = [[OakFileSystemSnapshotNode alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath: dir];
    
    while (enumerator)
    {
        NSDictionary *attr = [enumerator directoryAttributes];
        if (attr)
        {
            NSLog(@"%@", attr);
        }else
        {
            attr = [enumerator fileAttributes];
            NSLog(@"%@", attr);
        }
        
        enumerator = [enumerator nextObject];
    }
    
    return res;
}

- (id)initWithPath: (NSString *)path
{
    if ((self = [super init]))
    {
        _entries = _OakFileSystemSnapshotCollect(path);
    }
    
    return  self;
}

+ (NSDate *)modified: (NSString *) path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath: path
                                                       error: &error];
    if(error)
    {
        NSLog(@"in func: %s error: %@", __func__, error);
        return nil;
    }else
    {
        return [attr objectForKey: NSFileModificationDate];
    }
}


@end
