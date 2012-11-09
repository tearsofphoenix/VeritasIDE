#import "OTVStatusBar.h"
#import <OakAppKit/OakAppKit.h>
#import <OakFoundation/OakFoundation.h>

@interface OTVStatusBar ()

- (void)update;

@property (nonatomic, retain) NSTimer* recordingTimer;

@property (nonatomic, retain) NSImage* pulsedRecordingIndicator;

@end

const NSInteger BundleItemSelector = 1;

@implementation OTVStatusBar
@synthesize recordingTimer, pulsedRecordingIndicator, grammarName, symbolName, isMacroRecording, tabSize, softTabs;
@synthesize delegate;

- (void)update
{
	NSUInteger line = [[caretPosition minPosition] line];
    NSUInteger column = [[caretPosition minPosition] column];

	//NSString * lineNumberText = [NSString stringWithFormat: @"Line: %@\u2003Column: %@", OakTextPad(line+1, 4), OakTextPad(column+1, 3)];
    
	NSString * tabSizeText    = [NSString stringWithFormat: @"%s\u2003%@", (softTabs ? "Soft Tabs:" : "Tab Size:"), OakTextPad(tabSize, 4)];
    
	static NSImage* gearImage        = [[NSImage imageNamed: @"Statusbar Gear"
                                        inSameBundleAsClass: [self class]] retain];
	static NSImage* languageIcon     = [[NSImage imageNamed: @"Languages"
                                        inSameBundleAsClass: [self class]] retain];
    
    NSMutableArray *cells = [NSMutableArray array];
    
    OakStatusBarCell *infoCell = [OakStatusBarCell cellWithType: OakStatusBarInfo
                                                     target: nil action: NULL];
    [cells addObject: infoCell];
    
    OakStatusBarCell *popUp = [OakStatusBarCell cellWithType: OakStatusBarPopup
                                                      target: [self delegate]
                                                      action: @selector(showLanguageSelector:)];
    
    [popUp setText: (grammarName ?: @"-")];
    [popUp setImage: languageIcon];
    [popUp setMinSize: 110];

    [cells addObject: popUp];
    
    popUp = [OakStatusBarCell cellWithType: OakStatusBarPopup
                                    target: [self delegate]
                                    action: @selector(showBundleItemSelector:)];
    [popUp setImage: gearImage];
    [popUp setTag: BundleItemSelector];
    
    [cells addObject: popUp];
    
    popUp = [OakStatusBarCell cellWithType: OakStatusBarPopup
                                    target: [self delegate]
                                    action: @selector(showTabSizeSelector:)];
    [popUp setText: tabSizeText];

    [cells addObject: popUp];
    
    
    popUp = [OakStatusBarCell cellWithType: OakStatusBarPopup
                                    target: [self delegate]
                                    action: @selector(showSymbolSelector:)];
    [popUp setText: (symbolName ?: @"Symbol")];
    [popUp setMinSize: 200];
    [popUp setMaxSize: CGFLOAT_MAX];

    [cells addObject: popUp];
    
    OakStatusBarCell *buttonCell = [OakStatusBarCell cellWithType: OakStatusBarButton
                                                           target: [self delegate]
                                                           action: @selector(toggleMacroRecording:)];
    [buttonCell setImage: pulsedRecordingIndicator];
    [buttonCell noPadding];
    [buttonCell setMinSize: 17];
    
    [cells addObject: buttonCell];
    
    infoCell = [OakStatusBarCell cellWithType: OakStatusBarInfo
                                       target: nil
                                       action: NULL];
    [infoCell setMinSize: 15];
    
    [cells addObject: infoCell];

    [self setCells: cells];
}

- (void)updateMacroRecordingAnimation:(NSTimer*)aTimer
{
	NSImage* startImage = [NSImage imageNamed:@"RecordingMacro" inSameBundleAsClass:[self class]];
	self.pulsedRecordingIndicator = [[[NSImage alloc] initWithSize:startImage.size] autorelease];

	[pulsedRecordingIndicator lockFocus];
	CGFloat fraction = OakCap(0.00, 0.50 + 0.50 * sin(recordingTime), 1.0);
	[startImage drawAtPoint: NSZeroPoint
                   fromRect: NSZeroRect
                  operation: NSCompositeSourceOver
                   fraction: fraction];
	[pulsedRecordingIndicator unlockFocus];

	[self update];
	recordingTime += 0.075;
}

// ==============
// = Properties =
// ==============

- (void)setGrammarName:(NSString*)newGrammarName
{
	[grammarName release];
	grammarName = [newGrammarName copy];
	[self update];
}

- (void)setSymbolName:(NSString*)newSymbolName
{
	[symbolName release];
	symbolName = [newSymbolName copy];
	[self update];
}

- (void)setRecordingTimer:(NSTimer*)aTimer
{
	if(aTimer != recordingTimer)
	{
		[recordingTimer invalidate];
		[recordingTimer release];
		recordingTimer = [aTimer retain];
	}
}

- (void)setIsMacroRecording:(BOOL)flag
{
	isMacroRecording = flag;
	if(isMacroRecording)
	{
		recordingTime = 0;
		self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateMacroRecordingAnimation:) userInfo:nil repeats:YES];
	}
	else
	{
		self.pulsedRecordingIndicator = nil;
		self.recordingTimer = nil;
	}
	[self update];
}

- (void)setCaretPosition:(NSString *)range
{
    [caretPosition release];
	caretPosition = [[OakTextRange alloc] initWithString: range];
    
	[self update];
}

- (void)setTabSize:(int32_t)size
{
	tabSize = size;
	[self update];
}

- (void)setSoftTabs:(BOOL)flag
{
	softTabs = flag;
	[self update];
}

- (void)dealloc
{
	self.grammarName = nil;
	self.symbolName = nil;
	self.recordingTimer = nil;
	[super dealloc];
}
@end
