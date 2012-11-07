
enum
{
    kNodeTypeDirectory,
    kNodeTypeLink,
    kNodeTypeFile
};

typedef NSInteger OakFileSystemSnapshotNodeType;

@interface OakFileSystemSnapshotNode : NSObject
{
    NSArray *_entries;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic) OakFileSystemSnapshotNodeType type;
@property (nonatomic, retain) NSDate *modified;

- (NSArray *)entries;

@end


@interface OakFileSystemSnapshot : NSObject
{
    OakFileSystemSnapshotNode *_entries;
}

- (id)initWithPath: (NSString *)path;

@end

