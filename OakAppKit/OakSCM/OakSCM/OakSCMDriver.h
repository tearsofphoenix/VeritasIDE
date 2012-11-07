
@interface OakSCMDriver : NSObject
{
    NSString * _name;
    NSString * _wc_root_format_string;
    NSString * _required_executable;
    NSString * _resolved_executable;
}

- (id)initWithName: (NSString *)name
  rootFormatString: (NSString *)wcRootFormatString
requiredExecutable: (NSString *)requiredExecutable;

- (NSString *)branchNameForPath: (NSString *)wcPath;

- (NSDictionary *)statusForPath: (NSString *)wcPath;

- (NSString *)name;

- (BOOL)tracksDirectories;

- (NSString *)executableName;

@end


extern OakSCMDriver* driver_for_path (NSString * path, NSString ** wcPath);
