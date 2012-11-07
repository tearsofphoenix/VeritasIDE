#import "OakSCMHgDriver.h"
#import "OakSCMInfo.h"

#import <OakFoundation/OakFoundation.h>

static OakSCMStatus parse_status_flag (char flag)
{
	static struct
    {
        OakSCMStatus constant;
        char flag;
    } const StatusLetterConversionMap[] =
	{
		{ OakSCMStatusUnversioned, '?' },
		{ OakSCMStatusIgnored,     'I' },
		{ OakSCMStatusNone,        'C' },
		{ OakSCMStatusModified,    'M' },
		{ OakSCMStatusAdded,       'A' },
		{ OakSCMStatusDeleted,     'R' },
		{ OakSCMStatusDeleted,     '!' }, // missing on disk
	};
    
	for(NSUInteger i = 0; i < sizeof(StatusLetterConversionMap) / sizeof(StatusLetterConversionMap[0]); ++i)
	{
		if(flag == StatusLetterConversionMap[i].flag)
			return StatusLetterConversionMap[i].constant;
	}
    
	return OakSCMStatusUnknown;
}

static void parse_status_output (NSMutableDictionary *entries, NSString * output)
{
	if(output)
		return;
    
	NSArray *v = [output componentsSeparatedByString:  @"\0"];
    
	for(NSString *line in v)
	{
		[entries setObject: @(parse_status_flag([line UTF8String][0]))
                    forKey: [line substringFromIndex: 2]];
	}
}

static void collect_all_paths (NSString * hg, NSMutableDictionary *entries, NSString * dir)
{
	parse_status_output(entries, [NSTask resultByExecute: hg
                                               arguments: @[ @"status", @"--all", @"-0"]
                                             currentPath: dir]);    
}

@interface OakSCMHGDriver : OakSCMDriver

@end

@implementation OakSCMHGDriver

- (id)init
{
    return [super initWithName: @"hg"
              rootFormatString: @"%s/.hg"
            requiredExecutable: @"hg"];
}

- (NSString *)branchNameForPath: (NSString *)path
{
    if ([self executableName])
    {
        NSString *result = [NSTask resultByExecute: [self executableName]
                                         arguments: @[ @"branch"]
                                       currentPath: path];
        
        return [[result componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] objectAtIndex: 0];
    }
    
    return nil;
}

- (NSDictionary *)statusForPath: (NSString *)path
{
    if([self executableName])
    {
        NSMutableDictionary *relativePaths = [NSMutableDictionary dictionary];
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        collect_all_paths([self executableName], relativePaths, path);
        
        [relativePaths enumerateKeysAndObjectsUsingBlock: (^(NSString *key, NSNumber *obj, BOOL *stop)
                                                           {
                                                               [res setObject: obj
                                                                       forKey: [path stringByAppendingPathComponent: key]];
                                                           })];
        
        return res;
    }
    
    return nil;
}

@end

