#import "OakPasteboardWrapper.h"
#import <OakAppKit/OakPasteboard.h>
#import <OakFoundation/OakFoundation.h>
#import <ns/ns.h>

@interface OakMyClipBoardEntry : OakClipBoardEntry
{
    NSMutableDictionary *_options;
}

- (id)initWithContent: (NSString *)content
              options: (NSDictionary *)options;

- (NSDictionary *)options;

@end

@implementation OakMyClipBoardEntry

- (id)initWithContent: (NSString *)content
              options: (NSDictionary *)options
{
    if ((self = [super initWithContent: content]))
    {
        _options = [[NSMutableDictionary alloc] init];
        [_options setDictionary: options];
    }
    
    return self;
}

- (void)dealloc
{
    [_options release];
    
    [super dealloc];
}

- (NSDictionary *)options
{
    return _options;
}

@end

static id to_entry (OakPasteboardEntry* src, BOOL includeFindOptions)
{
	if(!src)
    {
		return nil;
    }
    
	NSMutableDictionary *map = [NSMutableDictionary  dictionary];
    
	NSMutableDictionary * plist = [src options];
    
    [map setDictionary: plist];
    
	if(includeFindOptions)
	{
        [map setObject: [[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsFindWrapAround] ? @"1" : @"0"
                forKey: @"wrapAround"];

        [map setObject: [[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsFindIgnoreCase] ? @"1" : @"0"
                forKey: @"ignoreCase"];
	}

    OakMyClipBoardEntry *entry = [[OakMyClipBoardEntry alloc] initWithContent: [src string]
                                                                      options: map];
    
	return [entry autorelease];
}

@interface OakMyPasteBoard : NSObject<OakClipBoard>
{
    OakPasteboard* pasteboard;
    BOOL includeFindOptions;
}

- (id)initWithName: (NSString *)name;

- (BOOL)isEmpty;

@end

@implementation OakMyPasteBoard

- (id)initWithName: (NSString *)name
{
    if ((self = [super init]))
    {
        pasteboard         = [[OakPasteboard pasteboardWithName: name] retain];
		includeFindOptions = [name isEqualToString: NSFindPboard];
    }
    
    return self;
}

- (void)dealloc
{
    [pasteboard release];
    
    [super dealloc];
}

- (BOOL)isEmpty
{
    return NO;
}

- (OakClipBoardEntry *)previous
{
    
}

- (OakClipBoardEntry *)current
{
    
}

- (OakClipBoardEntry *)next
{
    
}

- (void)addEntry: (OakClipBoardEntry *)entry
{
    [pasteboard addEntry: [OakPasteboardEntry pasteboardEntryWithString: [entry content]
                                                             andOptions: [entry options]]];
}

@end
//
//	entry_ptr previous ()                   { return to_entry([pasteboard previous], includeFindOptions); }
//	entry_ptr current () const              { return to_entry([pasteboard current], includeFindOptions); }
//	entry_ptr next ()                       { return to_entry([pasteboard next], includeFindOptions); }

id<OakClipBoard> get_clipboard (NSString* pboardName)
{
	return [[[OakMyPasteBoard alloc] initWithName: pboardName] autorelease];
}
