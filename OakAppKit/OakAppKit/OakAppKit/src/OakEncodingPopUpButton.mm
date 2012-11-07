#import "OakEncodingPopUpButton.h"
#import "NSMenu+Additions.h"
#import <OakFoundation/OakFoundation.h>
#import <ns/ns.h>
#import <text/parse.h>


static NSString* const kUserDefaultsAvailableEncodingsKey = @"availableEncodings";

@interface OakCharset : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSString *code;

@end

@implementation OakCharset


@end


static NSArray * OakDefaultEncodingList (void)
{
    NSArray *res = nil;
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:  @"Library/Application Support/TextMate/Charsets.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        path = [[NSBundle bundleForClass:[OakEncodingPopUpButton class]] pathForResource: @"Charsets"
                                                                                  ofType: @"plist"];
        res = [NSArray arrayWithContentsOfFile: path];
    }
    
    return res;
}

@interface OakMenuItem : NSObject

@property (nonatomic, retain) NSString *group;

@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) NSString *representedObject;

@end

@implementation OakMenuItem

@end

static id OakMenuItemMake(NSString *group, NSString *title,  NSString *rep)
{
    OakMenuItem *item = [[OakMenuItem alloc] init];
    [item setGroup: group];
    [item setTitle: title];
    [item setRepresentedObject: rep];
    
    return [item autorelease];
}


static NSMenuItem* PopulateMenuFlat (NSMenu* menu, NSArray *items, id target, SEL action, NSString * selected)
{
    NSMenuItem* res = nil;
    for(OakMenuItem *item in items)
    {
        NSMenuItem* menuItem = [menu addItemWithTitle: [NSString stringWithFormat: @"%@ - %@", [item group], [item title]]
                                               action: action
                                        keyEquivalent: @""];
        
        [menuItem setRepresentedObject: [item representedObject]];
        [menuItem setTarget: target];
        
        if([[item representedObject] isEqualToString: selected])
        {
            res = menuItem;
        }
    }
    
    return res;
}

static void PopulateMenuHierarchical(NSMenu* containingMenu, NSArray *items, id target, SEL action, NSString * selected)
{
    NSString * groupName = nil;
    NSMenu* menu = nil;
    
    for(OakMenuItem *item in items)
    {
        if(![groupName isEqualToString: [item group]])
        {
            groupName = [item group];
            
            menu = [[[NSMenu alloc] init] autorelease];
            [menu setAutoenablesItems: NO];
            [[containingMenu addItemWithTitle:  groupName
                                       action: NULL
                                keyEquivalent: @""] setSubmenu: menu];
        }
        
        NSMenuItem* menuItem = [menu addItemWithTitle: [item title]
                                               action: action
                                        keyEquivalent: @""];
        
        [menuItem setRepresentedObject: [item representedObject]];
        [menuItem setTarget: target];
        if([selected isEqualToString: [item representedObject]])
        {
            [menuItem setState: NSOnState];
        }
    }
}

@interface OakCustomizeEncodingsWindowController : NSWindowController
{
	NSMutableArray* encodings;
}

+ (OakCustomizeEncodingsWindowController*)sharedInstance;

@end

@interface OakEncodingPopUpButton ()
@property (nonatomic, retain) NSArray* availableEncodings;
@end

@implementation OakEncodingPopUpButton
@synthesize encoding, availableEncodings;

+ (void)initialize
{
	NSArray* encodings = @[ @"WINDOWS-1252", @"MACROMAN", @"ISO-8859-1", @"UTF-8", @"UTF-16LE", @"UTF-16BE", @"SHIFT_JIS", @"GB18030" ];
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{ kUserDefaultsAvailableEncodingsKey : encodings }];
}

- (void)updateAvailableEncodings
{
	NSMutableArray* encodings = [NSMutableArray array];
	for(NSString* str in [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsAvailableEncodingsKey])
		[encodings addObject:str];
    
	if(encoding && ![encodings containsObject:encoding])
		[encodings addObject:encoding];
    
	self.availableEncodings = encodings;
}

- (void)updateMenu
{
	NSMutableArray *items = [NSMutableArray array];
    
	NSString * currentEncodingsTitle = encoding;
	for(OakCharset *charset in OakDefaultEncodingList())
	{
		if([availableEncodings containsObject:  [charset code]])
		{
			NSArray *v = [[charset name] componentsSeparatedByString: @" – "];
			if([v count] == 2)
			{
				[items addObject: OakMenuItemMake([v objectAtIndex: 0], [v objectAtIndex: 1], [charset code])];
                
                if([encoding isEqualToString: [charset code]])
                {
					currentEncodingsTitle = [[charset name] retain];
                }
			}
		}
	}
    
	[[self menu] removeAllItems];
    
	firstMenuItem = nil;
	
    if([items count] >= 10)
	{
		firstMenuItem = [[self menu] addItemWithTitle:  currentEncodingsTitle
                                             action: NULL
                                      keyEquivalent: @""];
		[[self menu] addItem: [NSMenuItem separatorItem]];
        
		[self selectItem: firstMenuItem];
	}
    
	if([items count] < 10)
    {
        [self selectItem: PopulateMenuFlat(self.menu, items, self, @selector(selectEncoding:), encoding)];
	}else
    {
        PopulateMenuHierarchical(self.menu, items, self, @selector(selectEncoding:), encoding);
    }
    
	[self.menu addItem: [NSMenuItem separatorItem]];
    
	[[self.menu addItemWithTitle: @"Customize Encodings List…"
                          action: @selector(customizeAvailableEncodings:)
                   keyEquivalent: @""] setTarget: self];
}

- (id)initWithCoder:(NSCoder*)aCoder
{
	if(self = [super initWithCoder:aCoder])
	{
		encoding = [@"UTF-8" retain];
		[self updateAvailableEncodings];
		[self updateMenu];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
	}
	return self;
}

- (id)initWithFrame:(NSRect)aRect pullsDown:(BOOL)flag
{
	if(self = [super initWithFrame:aRect pullsDown:flag])
	{
		encoding = [@"UTF-8" retain];
		[self updateAvailableEncodings];
		[self updateMenu];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
	}
	return self;
}

- (id)init
{
	if(self = [self initWithFrame:NSZeroRect pullsDown:NO])
	{
		[self sizeToFit];
		if(NSWidth([self frame]) > 200)
			[self setFrameSize:NSMakeSize(200, NSHeight([self frame]))];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[encoding release];
	[availableEncodings release];
	[super dealloc];
}

- (void)selectEncoding:(NSMenuItem*)sender
{
	self.encoding = [sender representedObject];
}

- (void)setEncoding:(NSString*)newEncoding
{
	if(encoding == newEncoding || [encoding isEqualToString:newEncoding])
		return;
    
	[encoding release];
	encoding = [newEncoding retain];
	if(encoding && ![availableEncodings containsObject:encoding])
		[self updateAvailableEncodings];
	[self updateMenu];
}

- (void)setAvailableEncodings:(NSArray*)newEncodings
{
	if(availableEncodings == newEncodings || [availableEncodings isEqualToArray:newEncodings])
		return;
    
	[availableEncodings release];
	availableEncodings = [newEncodings retain];
	[self updateMenu];
}

- (void)customizeAvailableEncodings:(id)sender
{
	[[OakCustomizeEncodingsWindowController sharedInstance] showWindow:self];
	[self updateMenu];
}

- (void)userDefaultsDidChange:(NSNotification*)aNotification
{
	[self updateAvailableEncodings];
}
@end

// =========================================
// = Customize Encodings Window Controller =
// =========================================

static OakCustomizeEncodingsWindowController* SharedInstance;

@implementation OakCustomizeEncodingsWindowController
+ (OakCustomizeEncodingsWindowController*)sharedInstance
{
	return SharedInstance ?: [[OakCustomizeEncodingsWindowController new] autorelease];
}

- (id)init
{
	if(SharedInstance)
	{
		[self release];
	}
	else if((self = SharedInstance = [[super initWithWindowNibName:@"CustomizeEncodings"] retain]))
	{
		NSMutableSet *enabledEncodings = [NSMutableSet set];
        
		for(NSString* encodingLooper in [[NSUserDefaults standardUserDefaults] arrayForKey: kUserDefaultsAvailableEncodingsKey])
        {
			[enabledEncodings addObject: encodingLooper];
        }
        
		encodings = [NSMutableArray new];
        
		for(OakCharset *charset in OakDefaultEncodingList())
		{
			BOOL enabled = [enabledEncodings containsObject: [charset code]];
            
			[encodings addObject: (@{
                                        @"enabled" : @(enabled),
                                        @"name" : [charset name],
                                        @"charset" : [charset code]
                                   })];
		}
	}
	return self;
}

// ========================
// = NSTableView Delegate =
// ========================

- (BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex
{
	return [[aTableColumn identifier] isEqualToString:@"enabled"];
}

// ==========================
// = NSTableView DataSource =
// ==========================

- (NSInteger)numberOfRowsInTableView:(NSTableView*)aTableView
{
	return [encodings count];
}

- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex
{
	return [[encodings objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView*)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex
{
	[[encodings objectAtIndex:rowIndex] setObject:anObject forKey:[aTableColumn identifier]];
    
	NSMutableArray* newEncodings = [NSMutableArray array];
	for(NSDictionary* encoding in encodings)
	{
		if([[encoding objectForKey:@"enabled"] boolValue])
			[newEncodings addObject:[encoding objectForKey:@"charset"]];
	}
    
	[[NSUserDefaults standardUserDefaults] setObject:newEncodings forKey:kUserDefaultsAvailableEncodingsKey];
}
@end
