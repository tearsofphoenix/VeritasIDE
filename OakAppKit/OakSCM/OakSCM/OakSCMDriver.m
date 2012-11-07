
#import "OakSCMDriver.h"

@implementation OakSCMDriver

- (id)initWithName: (NSString *)name
  rootFormatString: (NSString *)wcRootFormatString
requiredExecutable: (NSString *)requiredExecutable
{
    if ((self = [super init]))
    {
        _name = [name retain];
        _wc_root_format_string = [wcRootFormatString retain];
        _required_executable = [requiredExecutable retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_wc_root_format_string release];
    [_required_executable release];
    
    [super dealloc];
}

- (NSString *)branchNameForPath: (NSString *)wcPath
{
    return nil;
}

- (NSDictionary *)statusForPath: (NSString *)wcPath
{
    return nil;
}

- (NSString *)name
{
    return _name;
}

- (BOOL)tracksDirectories
{
    return NO;
}

- (NSString *)executableName
{
    return _required_executable;
}

@end