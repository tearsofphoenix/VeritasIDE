
#import "OakSCMSVNDriver.h"

#import "OakSCMInfo.h"

#import <OakFoundation/OakFoundation.h>

static OakSCMStatus parse_status_string (const char * status)
{
	// Based on subversion/svn/status.c (generate_status_desc)
	static struct
    {
        const char *value;
        OakSCMStatus status;
        
    } StatusMap[] =
	{
		{ "none",        OakSCMStatusNone        },
		{ "normal",      OakSCMStatusNone        },
		{ "added",       OakSCMStatusAdded       },
		{ "missing",     OakSCMStatusDeleted     },
		{ "incomplete",  OakSCMStatusDeleted     },
		{ "deleted",     OakSCMStatusDeleted     },
		{ "replaced",    OakSCMStatusModified    },
		{ "modified",    OakSCMStatusModified    },
		{ "conflicted",  OakSCMStatusConflicted  },
		{ "obstructed",  OakSCMStatusConflicted  },
		{ "ignored",     OakSCMStatusIgnored     },
		{ "external",    OakSCMStatusNone        }, // No good way to represent external status so default to 'none'
		{ "unversioned", OakSCMStatusUnversioned },
	};
    
    for (NSUInteger iLooper = 0; iLooper < sizeof(StatusMap) / sizeof(StatusMap[0]); ++iLooper)
    {
        if (strcmp(StatusMap[iLooper].value, status) == 0)
        {
            return StatusMap[iLooper].status;
        }
    }
	return OakSCMStatusUnknown;
}

static void parse_status_output (NSMutableDictionary *entries, NSString * output)
{
	for(NSString *line in [output componentsSeparatedByString: @"\n"])
	{
		// Massaged Subversion output is as follows: 'FILE_STATUS    FILE_PROPS_STATUS    FILE_PATH'
		NSArray *cols = [line componentsSeparatedByString: @"    "];
		if([cols count] == 3)
		{
			NSString * file_status       = [cols objectAtIndex: 0];
			NSString * file_props_status = [cols objectAtIndex: 1];
			NSString * file_path         = [cols objectAtIndex: 2];
            
			// If the file's status is not normal/none, use the file's status, otherwise use the file's property status
			if(![file_status isEqualToString: @"normal"]
               || ![file_status isEqualToString: @"none"])
            {
                [entries setObject: @(parse_status_string([file_status UTF8String]))
                            forKey: file_path];
            }else
            {
                [entries setObject: @(parse_status_string([file_props_status UTF8String]))
                            forKey: file_path];
            }
		}
		else if([line length] > 0)
		{
			NSLog(@"TextMate/svn: Unexpected line: ‘%@’\n", line);
		}
	}
}

static NSDictionary *parse_info_output (NSString * str)
{
	NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
	for(NSString *line in [str componentsSeparatedByString: @"\n"])
	{
		NSUInteger n = [line rangeOfString: @":"].location;
        
		if(n != NSNotFound)
        {
            [res setObject: [line substringFromIndex: n + 2]
                    forKey: [line substringWithRange: NSMakeRange(0, n)]];
        }
	}
    
	return res;
}

static void collect_all_paths (NSString * svn, NSString * xsltPath, NSMutableDictionary *entries, NSString * dir)
{
	NSString * cmd = [NSString stringWithFormat: @"'%@' status --no-ignore --xml|/usr/bin/xsltproc '%@' -", svn, xsltPath];
    
	parse_status_output(entries, [NSTask resultByExecute: @"/bin/sh"
                                               arguments: @[@"-c", cmd]
                                             currentPath: dir]);
}

@implementation OakSCMSVNDriver

- (id)init
{
    if (self = [super initWithName: @"svn"
                  rootFormatString: @"%s/.svn"
                requiredExecutable: @"svn"])
    {
        CFBundleRef bundle = CFBundleGetBundleWithIdentifier(CFSTR("com.macromates.TextMate.scm"));
        if(bundle)
        {
            CFURLRef xsltURL = CFBundleCopyResourceURL(bundle, CFSTR("svn_status"), CFSTR("xslt"), NULL);
            if(xsltURL)
            {
                CFStringRef path = CFURLCopyFileSystemPath(xsltURL, kCFURLPOSIXPathStyle);
                if(path)
                {
                    _xslt_path = [(NSString *)path retain];
                    
                    CFRelease(path);
                }
                
                CFRelease(xsltURL);
            }
        }
        
        // TODO Tests should be linked against the full framework bundle.
        static NSString * SourceTreePath = @"../../../resources/svn_status.xslt";
        
        if(!_xslt_path && [SourceTreePath existsAsPath])
        {
            _xslt_path = SourceTreePath;
        }
        
        if(!_xslt_path)
        {
            NSLog(@"TextMate/svn: Unable to locate ‘svn_status.xslt’.\n");
        }
    }
    
    return self;
}

- (NSString *)branchNameForPath: (NSString *) wcPath
{
    if([self executableName])
    {
        NSString *result = [NSTask resultByExecute: [self executableName]
                                         arguments: @[ @"info"]
                                       currentPath: nil];
        return result;
    }
    
    return nil;
}

- (NSDictionary *)statusForPath: (NSString *)path
{
    if([self executableName] && _xslt_path)
    {
        NSMutableDictionary *relativePaths = [NSMutableDictionary dictionary];
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        
        collect_all_paths([self executableName], _xslt_path, relativePaths, path);
        
        [relativePaths enumerateKeysAndObjectsUsingBlock: (^(id key, id obj, BOOL *stop)
                                                           {
                                                               [res setObject: obj
                                                                       forKey: [path stringByAppendingPathComponent: key]];
                                                           })];
        return res;
    }
    return nil;
}

- (BOOL)tracksDirectories
{
    return YES;
}

@end
