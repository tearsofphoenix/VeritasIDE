#import "OakView.h"


@implementation OakView

@synthesize keyState;

- (id)initWithFrame:(NSRect)aFrame
{
	if((self = [super initWithFrame:aFrame]))
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSApplicationDidResignActiveNotification object:NSApp];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSWindowDidBecomeMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSWindowDidResignMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSWindowDidBecomeKeyNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyState:) name:NSWindowDidResignKeyNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)updateKeyState:(NSNotification*)aNotification
{
	BOOL isAppActive = [NSApp isActive];
	BOOL isWinMain   = [[self window] isMainWindow];
	BOOL isWinKey    = [[self window] isKeyWindow];
	BOOL isViewKey   = isFirstResponder;

	NSUInteger newState =
		(isAppActive ? OakViewApplicationIsActiveMask  : 0) |
		(isWinMain   ? OakViewWindowIsMainMask         : 0) |
		(isWinKey    ? OakViewWindowIsKeyMask          : 0) |
		(isViewKey   ? OakViewViewIsFirstResponderMask : 0);

	if(newState != self.keyState)
		self.keyState = newState;
}

- (BOOL)becomeFirstResponder  { isFirstResponder = YES; [self updateKeyState:nil]; return YES; }
- (BOOL)resignFirstResponder  { isFirstResponder = NO;  [self updateKeyState:nil]; return YES; }
@end
