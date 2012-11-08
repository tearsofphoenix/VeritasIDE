#import "OakOpenWithMenu.h"
#import "NSMenuItem+Additions.h"
#import "NSMenu+Additions.h"
#import <OakFoundation/NSString+Additions.h>



//std::string display_name (NSString * p, NSUInteger n)
//{
////    NSString * path = normalize(p);
////    std::string res(system_display_name(path));
////
////    std::string::const_reverse_iterator  last = path.rend();
////    std::string::const_reverse_iterator  to   = std::find(path.rbegin(), last, '/');
////
////    if(n > 0 && to != last)
////    {
////        std::string::const_reverse_iterator from = to;
////        std::string components;
////        for(; n > 0 && from != last; --n)
////        {
////            if(components.size() > 0)
////                components = "/" + components;
////            components = system_display_name(std::string(path.begin(), from.base()-1)) + components;
////            if(n > 0)
////                from = std::find(++from, last, '/');
////        }
////
////        res += " — " + components;
////    }
////
////    return res;
//}


static NSArray *ApplicationURLsForPaths (NSSet* paths)
{
	NSMutableArray *res = [NSMutableArray array];
	NSMutableSet* defaultApplicationURLs = [NSMutableSet set];
	NSMutableSet* allApplicationURLs = [NSMutableSet set];
    
	for(NSString* path in paths)
	{
		NSURL* fileURL = [NSURL fileURLWithPath:path];
		NSArray* applicationURLs = [(NSArray*)LSCopyApplicationURLsForURL((CFURLRef)fileURL, kLSRolesAll) autorelease];
		NSURL* defaultApplicationURL = nil;
		if(noErr == LSGetApplicationForURL((CFURLRef)fileURL, kLSRolesAll, NULL, (CFURLRef*)&defaultApplicationURL))
		{
			if(![applicationURLs containsObject:defaultApplicationURL])
				applicationURLs = [applicationURLs arrayByAddingObject:defaultApplicationURL];
			[defaultApplicationURLs addObject:defaultApplicationURL];
		}
		if(allApplicationURLs.count == 0)
            [allApplicationURLs setSet:[NSSet setWithArray:applicationURLs]];
		else	[allApplicationURLs intersectSet:[NSSet setWithArray:applicationURLs]];
	}
    
	if(allApplicationURLs.count == 0)
		return res;
    
	NSMutableDictionary *apps = [NSMutableDictionary dictionary];
    
	for(NSURL* appURL in allApplicationURLs)
	{
		NSString * appName = @"VeritasIDE";
		NSBundle* appBundle        = [NSBundle bundleWithPath:appURL.path];
		NSString* appVersion       = [appBundle objectForInfoDictionaryKey: @"CFBundleShortVersionString"] ?: ([appBundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"???");
        
        NSMutableDictionary *dict = [apps objectForKey: appName];
        if (!dict)
        {
            dict = [[NSMutableDictionary alloc] init];
            
            [apps setObject: dict
                     forKey: appName];
            
            [dict release];
        }
        
        [dict setObject: appURL
                 forKey: appVersion];
	}
    
	NSURL* defaultApplicationURL = defaultApplicationURLs.count == 1 ? defaultApplicationURLs.anyObject : nil;
    
    [apps enumerateKeysAndObjectsUsingBlock: (^(NSString *appNamekey, NSDictionary *obj, BOOL *stop)
                                              {
                                                  
                                                  [obj enumerateKeysAndObjectsUsingBlock: (^(NSString *appVersionkey, NSURL *urlObj, BOOL *stop)
                                                                                           {
                                                                                               
                                                                                               NSString* appName = appNamekey;
                                                                                               NSURL* appURL = urlObj;
                                                                                               
                                                                                               if([defaultApplicationURL isEqual: appURL])
                                                                                               {
                                                                                                   appName = [NSString stringWithFormat:@"%@ (default)", appName];
                                                                                               }
                                                                                               
                                                                                               //			if(appIter->second.size() > 1) // we have more than one version
                                                                                               //            {
                                                                                               //				appName = [NSString stringWithFormat:@"%@ (%@)", appName, appVersionkey];
                                                                                               //            }
                                                                                               
                                                                                               [res addObject:  @[appName, appURL]];
                                                                                           })];
                                              })];
    
	return res;
}

static OakOpenWithMenu* SharedInstance;

@implementation OakOpenWithMenu
+ (id)sharedInstance
{
	return SharedInstance ?: [[self new] autorelease];
}

- (id)init
{
	if(SharedInstance)
        [self release];
	else	self = SharedInstance = [[super init] retain];
	return SharedInstance;
}

+ (void)addOpenWithMenuForPaths:(NSSet*)paths toMenuItem:(NSMenuItem*)item
{
	NSMenu* submenu = [[NSMenu new] autorelease];
	[submenu setAutoenablesItems:NO];
	[submenu setDelegate:[OakOpenWithMenu sharedInstance]];
    
	[item setRepresentedObject:paths];
	[item setSubmenu:submenu];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
	NSMenuItem* superItem = [menu parentMenuItem];
	if(menu.numberOfItems > 0 || !superItem)
		return;
    
	NSArray *appURLs = ApplicationURLsForPaths(superItem.representedObject);
    
	if([appURLs count] == 0)
	{
		[[menu addItemWithTitle: @"No Suitable Applications Found"
                         action: @selector(dummy:)
                  keyEquivalent: @""] setEnabled:NO];
		return;
	}
    
	for(NSArray *app in appURLs)
	{
		NSMenuItem* menuItem = [menu addItemWithTitle: [app objectAtIndex: 0]
                                               action: @selector(openWith:)
                                        keyEquivalent: @""];
		[menuItem setIconForFile: [[app objectAtIndex: 1] path]];
		[menuItem setTarget: self];
		[menuItem setRepresentedObject: [app objectAtIndex: 1]];
	}
    
	if([appURLs count] > 1)
    {
		[menu insertItem: [NSMenuItem separatorItem]
                 atIndex: 1];
    }
}

- (void)openWith:(id)sender
{
	NSURL* applicationURL   = [sender representedObject];
	NSSet* filePaths = [[[sender menu] parentMenuItem] representedObject];
    
	NSMutableArray* fileURLs = [NSMutableArray arrayWithCapacity:filePaths.count];
	for(NSString* filePath in filePaths)
		[fileURLs addObject:[NSURL fileURLWithPath:filePath]];
	[[NSWorkspace sharedWorkspace] openURLs:fileURLs
                    withAppBundleIdentifier:[[NSBundle bundleWithPath:applicationURL.path] bundleIdentifier]
                                    options:0
             additionalEventParamDescriptor:NULL
                          launchIdentifiers:NULL];
}
@end
