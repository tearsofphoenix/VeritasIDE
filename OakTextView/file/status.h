
enum 
{
	kFileTestWritable,
	kFileTestWritableByRoot,
	kFileTestNotWritable,
	kFileTestNotWritableButOwner,
	kFileTestNoParent,
	kFileTestReadOnly,
	kFileTestUnhandled,
};

typedef NSInteger file_status_t;

extern file_status_t OakFileStatus (NSString * path);
