
#import "OakSCMGitDriver.h"
#import "OakSCMInfo.h"

#import <OakFoundation/OakFoundation.h>

static OakSCMStatus parse_status_flag (char flag)
{
	static struct
    {
        char flag;
        OakSCMStatus constant;
    }
    StatusLetterConversionMap[] =
	{
		{ '?', OakSCMStatusUnknown },
		{ 'I', OakSCMStatusIgnored     },
		{ 'H', OakSCMStatusNone        },
		{ 'M', OakSCMStatusModified    },
		{ 'A', OakSCMStatusAdded       },
		{ 'D', OakSCMStatusDeleted     },
		{ 'U', OakSCMStatusConflicted  },
		{ 'T', OakSCMStatusModified    }  // type change, e.g. symbolic link → regular file
	};
    
	for(NSUInteger i = 0; i < sizeof(StatusLetterConversionMap) / sizeof(StatusLetterConversionMap[0]); ++i)
	{
		if(flag == StatusLetterConversionMap[i].flag)
        {
			return StatusLetterConversionMap[i].constant;
        }
	}
    
	return OakSCMStatusUnknown;
}

static void parse_diff (NSMutableDictionary *entries, NSString * output)
{
	if(!output)
		return;
    
	NSArray *v = [output componentsSeparatedByString: @"\0"];
    
	for(NSUInteger i = 0; i < [v count]; i += 2)
    {
        NSString *key = [v objectAtIndex: i + 1];
        NSString *flag = [v objectAtIndex: i];
        
        [entries setObject: @(parse_status_flag(*[flag UTF8String]))
                    forKey: key];
    }
}

static void parse_ls (NSMutableDictionary *entries, NSString * output, OakSCMStatus state)
{
	if(!output)
		return;
    
	NSArray *v = [output componentsSeparatedByString: @"\0"];
    
	for(NSString *str in v)
	{
        id value = @(state != OakSCMStatusUnknown ? state : parse_status_flag(*[[str substringWithRange: NSMakeRange(0, 1)] UTF8String]));
        
        [entries setObject: value
                    forKey: [str substringFromIndex: 2]];
	}
}

static NSString * copy_git_index (NSString * dir)
{
	NSString * gitDir = [dir stringByAppendingPathComponent: @".git"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath: gitDir
                                    isDirectory: &isDirectory];
	if(exists && isDirectory)
	{
		// Submodules have their git dir in the super project (starting with 1.7.6) — if we know the user has 1.7.6 we should ask git for the git dir using: git rev-parse --resolve-git-dir /path/to/repository/.git
        NSError *error = nil;
        
		NSArray * contents = [fileManager contentsOfDirectoryAtPath: gitDir
                                                              error:  &error];
        if ([contents count] > 0)
        {
            if (error)
            {
                NSLog(@"in func: %s error: %@", __func__, error);
                return nil;
            }else
            {
                NSString *setting = [contents objectAtIndex: 0];
                
                if([setting rangeOfString: @"gitdir: "].location == 0
                   && [setting UTF8String][[setting length] - 1] == '\n')
                {
                    gitDir = [dir stringByAppendingPathComponent: [setting substringWithRange: NSMakeRange(8, [setting length] - 9)]];
                }
            }
        }
	}
    
	NSString * indexPath = [gitDir stringByAppendingPathComponent: @"index"];
    
	if([[NSFileManager defaultManager] fileExistsAtPath: indexPath])
	{
		NSString * tmpIndex = [NSTemporaryDirectory() stringByAppendingPathComponent: @"git-index"];
        
        NSError *error = nil;
        
		if([[NSFileManager defaultManager] copyItemAtPath: indexPath
                                                   toPath: tmpIndex
                                                    error: &error])
        {
			return tmpIndex;
        }
        
        error = nil;
        [[NSFileManager defaultManager] removeItemAtPath: tmpIndex
                                                   error: &error];
	}
	else
	{
		NSLog(@"*** missing git index: %@\n", indexPath);
	}
    
	return nil;
}

static void collect_all_paths (NSString * git, NSMutableDictionary *entries, NSString * dir)
{
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary: [[NSProcessInfo processInfo] environment]];
    
    [env setObject: dir
            forKey: @"PWD"];
    
	BOOL haveHead = [[NSTask resultByExecute: git
                                   arguments: @[ @"show-ref", @"-qh"]
                                 currentPath: dir] length] > 0;
    
	NSString * tmpIndex = copy_git_index(dir);
	if(tmpIndex)
	{
        [env setObject: tmpIndex
                forKey: @"GIT_INDEX_FILE"];
        
        [NSTask launchedTaskWithLaunchPath: git
                                 arguments: @[ @"update-index", @"-q", @"--unmerged", @"--ignore-missing", @"--refresh"]];
        
		// All files part of the repository (index)
		if(haveHead)
        {
            parse_ls(entries, [NSTask resultByExecute: git
                                            arguments: @[@"ls-files", @"--exclude-standard", @"-zt"]
                                          currentPath: dir], 0);
        }
		else
        {
            parse_ls(entries, [NSTask resultByExecute: git
                                            arguments: @[ @"ls-files", @"--exclude-standard", @"-zt"]
                                          currentPath: dir] , OakSCMStatusAdded);
        }
        
		// Modified, Deleted (on disk, not staged)
		parse_diff(entries, [NSTask resultByExecute: git
                                          arguments: @[ @"diff-files", @"--name-status", @"--ignore-submodules=dirty", @"-z"]
                                        currentPath: dir]);
        
		// Added (to index), Deleted (from index)
		if(haveHead)
        {
			parse_diff(entries, [NSTask resultByExecute: git
                                              arguments: @[@"diff-index", @"--name-status", @"--ignore-submodules=dirty", @"-z", @"--cached", @"HEAD"]
                                            currentPath: dir]);
        }
	}
    
	// All files with ‘other’ status
	parse_ls(entries, [NSTask resultByExecute: git
                                    arguments: @[@"ls-files", @"--exclude-standard", @"-zto"]
                                  currentPath: dir], 0);
    
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath: tmpIndex
                                               error: &error];
    if (error)
    {
        NSLog(@"in func: %s error: %@", __func__, error);
    }
}

static OakSCMStatus status_for (NSString *root)
{
	if(![root isDirectory])
    {
		return [root status];
    }
    
	NSUInteger untracked = 0;
    NSUInteger ignored = 0;
    NSUInteger tracked = 0;
    NSUInteger modified = 0;
    NSUInteger added = 0;
    NSUInteger deleted = 0;
    NSUInteger mixed = 0;
    
	for(id entry in [root entries])
	{
		switch(status_for(entry))
		{
			case OakSCMStatusUnversioned:  ++untracked; break;
			case OakSCMStatusIgnored:      ++ignored;   break;
			case OakSCMStatusNone:         ++tracked;   break;
			case OakSCMStatusModified:     ++modified;  break;
			case OakSCMStatusAdded:        ++added;     break;
			case OakSCMStatusDeleted:      ++deleted;   break;
			case OakSCMStatusMixed:        ++mixed;     break;
		}
	}
	
	if(mixed > 0)
    {
        return OakSCMStatusMixed;
    }
	
	NSUInteger total = untracked + ignored + tracked + modified + added + deleted;
	
	if(total == untracked) return OakSCMStatusUnversioned;
	if(total == ignored)   return OakSCMStatusIgnored;
	if(total == tracked)   return OakSCMStatusNone;
	if(total == modified)  return OakSCMStatusModified;
	if(total == added)     return OakSCMStatusAdded;
	if(total == deleted)   return OakSCMStatusDeleted;
	
	if(total > 0)
    {
        return OakSCMStatusMixed;
    }
	
	return OakSCMStatusNone;
}

static void filter (NSMutableDictionary *statusMap, NSString * root, NSString * base)
{
	for(id entry in [root entries])
	{
		OakSCMStatus status = status_for(entry);
        [statusMap setObject: @(status)
                      forKey: [base stringByAppendingPathComponent: [entry path]]];

		if([entry isDirectory] && status != OakSCMStatusIgnored)
        {
			filter(statusMap, [entry path], base);
        }
	}
}

@implementation OakSCMGitDriver

- (id)init
{
    return [super initWithName: @"git"
              rootFormatString: @"%s/.git"
            requiredExecutable: @"git"];
}

- (NSString *)branchNameForPath: (NSString *)wcPath
{
    if([self executableName])
    {
        
        BOOL haveHead = [[NSTask resultByExecute: [self executableName]
                                       arguments: @[ @"show-ref", @"-qh"]
                                     currentPath: wcPath] boolValue];
        if(haveHead)
        {
            NSString * branchName = [NSTask resultByExecute: [self executableName]
                                                  arguments: @[ @"symbolic-ref", @"HEAD"]
                                                currentPath: wcPath];
            
            branchName = [[branchName componentsSeparatedByString: @"\n"] objectAtIndex: 0];
            
            if([branchName rangeOfString: @"refs/heads/"].location == 0)
            {
                branchName = [branchName substringFromIndex: strlen("refs/heads/")];
            }
            
            return branchName;
        }
    }
    
    return nil;
}

@end


