#include "status.h"

#include <sys/stat.h>


file_status_t OakFileStatus (NSString * path)
{
    if(access([path UTF8String], W_OK) == 0)
    {
        return kFileTestWritable;
    }
    else if(errno == EROFS)
    {
        return kFileTestReadOnly;
    }
    else if(errno == ENOENT)
    {
        NSString *parent = [path stringByDeletingLastPathComponent];
        
        if(access([parent UTF8String], W_OK) == 0)
            return kFileTestWritable;
        else if(errno == EROFS)
            return kFileTestReadOnly;
        else if(errno == ENOENT)
            return kFileTestNoParent;
        else if(errno == EACCES)
        {
            return kFileTestWritableByRoot; // ???
        }
        else
        {
            NSLog(@"stat(\"%@\"), W_OK", parent);
        }
    }
    else if(errno == EACCES)
    {
        struct stat sbuf;
        
        if(stat([path UTF8String], &sbuf) == 0)
        {
            if((sbuf.st_mode & S_IWUSR) == 0)
            {
                if(sbuf.st_uid == getuid())
                    return kFileTestNotWritableButOwner;
                else	return kFileTestNotWritable;
            }
            else if(sbuf.st_uid != getuid())
            {
                return kFileTestWritableByRoot; // ???
            }
            else
            {
                fprintf(stderr, "file mode %x\n", sbuf.st_mode);
            }
        }
        else if(errno == EACCES)
        {
            return kFileTestWritableByRoot;
        }
        else
        {
            NSLog(@"stat(\"%@\")", path);
        }
    }
    else
    {
        NSLog(@"stat(\"%@\"), W_OK", path);
    }
    
    return kFileTestUnhandled;
}
