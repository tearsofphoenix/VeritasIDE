/*
	TODO Filter duplicates
*/

#import "OakPasteboard.h"
#import "OakPasteboardSelector.h"

#import <OakFoundation/OakFoundation.h>

NSString*  NSReplacePboard                    = @"NSReplacePboard";
NSString*  OakPasteboardDidChangeNotification = @"OakClipboardDidChangeNotification";
NSString*  OakPasteboardOptionsPboardType     = @"OakPasteboardOptionsPboardType";

NSString*  kUserDefaultsFindWrapAround        = @"findWrapAround";
NSString*  kUserDefaultsFindIgnoreCase        = @"findIgnoreCase";

NSString*  OakFindIgnoreWhitespaceOption      = @"ignoreWhitespace";
NSString*  OakFindFullWordsOption             = @"fullWordMatch";
NSString*  OakFindRegularExpressionOption     = @"regularExpression";

NSString*  kUserDefaultsDisablePersistentClipboardHistory = @"disablePersistentClipboardHistory";

@implementation OakPasteboardEntry
@synthesize string, options;

- (id)initWithString: (NSString*)aString
          andOptions: (NSDictionary*)someOptions
{
	assert(aString != nil);
	if(self = [super init])
	{
		self.string = aString;
		options = [[NSMutableDictionary alloc] initWithDictionary:someOptions];
	}
	return self;
}

- (void)dealloc
{
	[string release];
	[options release];
	[super dealloc];
}

+ (OakPasteboardEntry*)pasteboardEntryWithString:(NSString*)aString andOptions:(NSDictionary*)someOptions
{
	return [[[self alloc] initWithString:aString andOptions:someOptions] autorelease];
}

+ (OakPasteboardEntry*)pasteboardEntryWithString:(NSString*)aString
{
	return [self pasteboardEntryWithString:aString andOptions:nil];
}

- (void)setOptions:(NSDictionary*)aDictionary
{
	if(options == aDictionary)
		return;
	[options release];
	options = [[NSMutableDictionary dictionaryWithDictionary:aDictionary] retain];
}

- (BOOL)isEqual:(id)otherEntry
{
	return [otherEntry isKindOfClass:[self class]] && [string isEqual:[otherEntry string]];
}

- (BOOL)fullWordMatch       { return [[options objectForKey:OakFindFullWordsOption] boolValue]; };
- (BOOL)ignoreWhitespace    { return [[options objectForKey:OakFindIgnoreWhitespaceOption] boolValue]; };
- (BOOL)regularExpression   { return [[options objectForKey:OakFindRegularExpressionOption] boolValue]; };

- (void)setOption:(NSString*)aKey toBoolean:(BOOL)flag
{
	if(!flag)
	{
		[options removeObjectForKey:aKey];
		return;
	}

	if(!options)
		options = [[NSMutableDictionary alloc] init];
	[options setObject:@YES forKey:aKey];
}

- (void)setFullWordMatch:(BOOL)flag       { return [self setOption:OakFindFullWordsOption toBoolean:flag]; };
- (void)setIgnoreWhitespace:(BOOL)flag    { return [self setOption:OakFindIgnoreWhitespaceOption toBoolean:flag]; };
- (void)setRegularExpression:(BOOL)flag   { return [self setOption:OakFindRegularExpressionOption toBoolean:flag]; };

- (NSStringCompareOptions)findOptions
{
	return (
		([self fullWordMatch]       ? NSLiteralSearch         : 0) |
		([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsFindIgnoreCase] ? NSCaseInsensitiveSearch : 0) |
		([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsFindWrapAround] ? NSRegularExpressionSearch : 0) |
		([self ignoreWhitespace]    ? NSCaseInsensitiveSearch  : 0) |
		([self regularExpression]   ? NSRegularExpressionSearch : 0));
}

- (void)setFindOptions:(NSStringCompareOptions)findOptions
{
	self.fullWordMatch     = (findOptions & NSLiteralSearch        ) != 0;
	self.ignoreWhitespace  = (findOptions & NSRegularExpressionSearch ) != 0;
	self.regularExpression = (findOptions & NSRegularExpressionSearch) != 0;
}

- (NSDictionary*)asDictionary
{
	NSMutableDictionary* res = [NSMutableDictionary dictionaryWithDictionary:options];
	if(string) // FIXME, how can this happen? Seems to happen when deleting preferences and exiting, likely bringing up the Find window first
		[res setObject:string forKey:@"string"];
	return res;
}
@end

@interface OakPasteboard (Private)
- (void)checkForExternalPasteboardChanges;
@end

// ============================
// = Event Loop Idle Callback =
// ============================

namespace
{
	struct event_loop_idle_callback_t;
	static event_loop_idle_callback_t& idle_callback ();

	struct event_loop_idle_callback_t
	{
		event_loop_idle_callback_t () : _running(false) { _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 100, &callback, NULL); start(); }
		~event_loop_idle_callback_t ()                  { stop(); CFRelease(_observer); }

		void start ()
		{
			if(_running)
				return;
			_running = true;
			CFRunLoopAddObserver(CFRunLoopGetCurrent(), _observer, kCFRunLoopCommonModes);
		}

		void stop ()
		{
			if(!_running)
				return;
			_running = false;
			CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), _observer, kCFRunLoopCommonModes);
		}

		void add (OakPasteboard* aPasteboard)
        {
            [_pasteboards addObject: aPasteboard];
        }
        
		void remove (OakPasteboard* aPasteboard)
        {
            [_pasteboards removeObject: aPasteboard];
        }

	private:
		static void callback (CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info)
		{
			for(id it in idle_callback()._pasteboards)
            {
				[it checkForExternalPasteboardChanges];
            }
		}

		bool _running;
		CFRunLoopObserverRef _observer;
		NSMutableSet *_pasteboards;
	};

	static event_loop_idle_callback_t& idle_callback ()
	{
		static event_loop_idle_callback_t res;
		return res;
	}
}

@implementation OakPasteboard

@synthesize avoidsDuplicates, auxiliaryOptionsForCurrent;

- (NSPasteboard*)pasteboard
{
	return [NSPasteboard pasteboardWithName:pasteboardName];
}

- (void)saveToDefaults
{
	if([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDisablePersistentClipboardHistory] boolValue])
		return [[NSUserDefaults standardUserDefaults] removeObjectForKey:pasteboardName];

	NSArray* tmp = [entries count] < 50 ? entries : [entries subarrayWithRange:NSMakeRange([entries count]-50, 50)];
	[[NSUserDefaults standardUserDefaults] setObject:[tmp valueForKey:@"asDictionary"] forKey:pasteboardName];
}

- (void)checkForExternalPasteboardChanges
{

	if(changeCount != [[self pasteboard] changeCount])
	{
		NSString* onClipboard = [[self pasteboard] availableTypeFromArray:@[ NSStringPboardType ]] ? [[self pasteboard] stringForType:NSStringPboardType] : nil;
		NSString* onStack = [([entries count] == 0 ? nil : [entries objectAtIndex:index]) string];
		changeCount = [[self pasteboard] changeCount];
		if((onClipboard && !onStack) || (onClipboard && onStack && ![onStack isEqualToString:onClipboard]))
		{
			id options = [[self pasteboard] availableTypeFromArray:@[ OakPasteboardOptionsPboardType ]] ? [[self pasteboard] propertyListForType:OakPasteboardOptionsPboardType] : nil;
			[entries addObject:[OakPasteboardEntry pasteboardEntryWithString:onClipboard andOptions:options]];
			index = [entries count]-1;
			self.auxiliaryOptionsForCurrent = nil;

			[[NSNotificationCenter defaultCenter] postNotificationName:OakPasteboardDidChangeNotification object:self];
			[self saveToDefaults];
		}
	}
}

- (void)applicationDidBecomeActiveNotification:(id)sender
{
	[self checkForExternalPasteboardChanges];
	idle_callback().start();
}

- (void)applicationDidResignActiveNotification:(id)sender
{
	idle_callback().stop();
}

- (void)setIndex:(NSUInteger)newIndex
{
	if(index != newIndex)
	{
		index = newIndex;
		self.auxiliaryOptionsForCurrent = nil;
		if(OakPasteboardEntry* current = [entries count] == 0 ? nil : [entries objectAtIndex:index])
		{
			[[self pasteboard] declareTypes:@[ NSStringPboardType, OakPasteboardOptionsPboardType ] owner:nil];
			[[self pasteboard] setString:[current string] forType:NSStringPboardType];
			[[self pasteboard] setPropertyList:[current options] forType:OakPasteboardOptionsPboardType];
			changeCount = [[self pasteboard] changeCount];

			[[NSNotificationCenter defaultCenter] postNotificationName:OakPasteboardDidChangeNotification object:self];
		}
	}
}

- (id)initWithName:(NSString*)aName
{
	if(self = [super init])
	{
		pasteboardName = [aName retain];

		entries = [NSMutableArray new];
		if(![[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDisablePersistentClipboardHistory] boolValue])
		{
			if(NSArray* history = [[NSUserDefaults standardUserDefaults] arrayForKey:pasteboardName])
			{
				for(NSDictionary* entry in history)
				{
					NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:entry];
					[dict removeObjectForKey:@"string"];
					if(NSString* str = [entry objectForKey:@"string"])
						[entries addObject:[OakPasteboardEntry pasteboardEntryWithString:str andOptions:dict]];
				}

				index = [entries count]-1;
			}
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:NSApp];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResignActiveNotification:) name:NSApplicationDidResignActiveNotification object:NSApp];
		[self checkForExternalPasteboardChanges];
		idle_callback().add(self);
	}
	return self;
}

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
	[self saveToDefaults];
}

- (void)dealloc
{
	idle_callback().remove(self);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:NSApp];
	[pasteboardName release];
	[entries release];
	[auxiliaryOptionsForCurrent release];
	[super dealloc];
}

+ (OakPasteboard*)pasteboardWithName:(NSString*)aName
{
	static NSMutableDictionary* SharedInstances = [NSMutableDictionary new];
	if(![SharedInstances objectForKey:aName])
	{
		[SharedInstances setObject:[[[self alloc] initWithName:aName] autorelease] forKey:aName];
		if(![aName isEqualToString:NSGeneralPboard])
			[[SharedInstances objectForKey:aName] setAvoidsDuplicates:YES];
	}

	OakPasteboard* res = [SharedInstances objectForKey:aName];
	[res checkForExternalPasteboardChanges];
	return res;
}

- (void)addEntry:(OakPasteboardEntry*)anEntry
{
	[self checkForExternalPasteboardChanges];
	if(avoidsDuplicates && [[entries lastObject] isEqual:anEntry])
	{
		index = [entries count]-1;
		self.auxiliaryOptionsForCurrent = nil;
	}
	else if(!avoidsDuplicates || ![[self current] isEqual:anEntry])
	{
		[entries addObject:anEntry];
		[self setIndex:[entries count]-1];
	}
	[self saveToDefaults];
}

- (OakPasteboardEntry*)previous
{
	[self checkForExternalPasteboardChanges];
	[self setIndex:index == 0 ? index : index-1];
	return [self current];
}

- (OakPasteboardEntry*)current
{
	[self checkForExternalPasteboardChanges];
	return [entries count] == 0 ? nil : [entries objectAtIndex:index];
}

- (OakPasteboardEntry*)next
{
	[self checkForExternalPasteboardChanges];
	[self setIndex:index+1 == [entries count] ? index : index+1];
	return [self current];
}

- (void)setEntries:(NSArray*)newEntries
{
	if(![newEntries isEqual:entries])
	{
		[entries release];
		entries = [newEntries mutableCopy];
		index = [entries count]-1;
		self.auxiliaryOptionsForCurrent = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:OakPasteboardDidChangeNotification object:self];
		[self saveToDefaults];
	}
}

- (BOOL)selectItemAtPosition:(NSPoint)location withWidth:(CGFloat)width respondToSingleClick:(BOOL)singleClick
{
	[self checkForExternalPasteboardChanges];

	NSUInteger selectedRow = ([entries count]-1) - index;
	OakPasteboardSelector* pasteboardSelector = [OakPasteboardSelector sharedInstance];
	[pasteboardSelector setEntries:[[entries reverseObjectEnumerator] allObjects]];
	[pasteboardSelector setIndex:selectedRow];
	if(width)
		[pasteboardSelector setWidth:width];
	if(singleClick)
		[pasteboardSelector setPerformsActionOnSingleClick];
	selectedRow = [pasteboardSelector showAtLocation:location];

	[self setEntries:[[[pasteboardSelector entries] reverseObjectEnumerator] allObjects]];
	[self setIndex:([entries count]-1) - selectedRow];

	return [pasteboardSelector shouldSendAction];
}

- (void)selectItemAtPosition:(NSPoint)aLocation andCall:(SEL)aSelector
{
	if([self selectItemAtPosition:aLocation withWidth:0 respondToSingleClick:NO])
		[NSApp sendAction:aSelector to:nil from:self];
}

- (void)selectItemForControl:(NSView*)controlView
{
	NSPoint origin = [[controlView window] convertBaseToScreen:[controlView frame].origin];
	[self selectItemAtPosition:origin withWidth:[controlView frame].size.width respondToSingleClick:YES];
}
@end
