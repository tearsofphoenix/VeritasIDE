#import "OakPopOutAnimation.h"
#import "NSImage+Additions.h"
#import <OakFoundation/OakFoundation.h>

static CGFloat const kExtendWidth  = 6;
static CGFloat const kExtendHeight = 1;
static CGFloat const kRectXRadius  = 6;
static CGFloat const kRectYRadius  = 6;
static double const  kGrowDuration = 0.10;
static double const  kFadeDuration = 0.60;

@interface OakPopOutView : NSView
{
	NSRect baseFrame;
	NSImage* contentImage;
	NSDate* animationStartTime;

	double growDuration;
	double fadeDuration;
}
@property (nonatomic, retain) NSDate* animationStartTime;
@property (nonatomic, retain) NSImage* contentImage;
- (void)startAnimation:(id)sender;
@end

void OakShowPopOutAnimation (NSRect aRect, NSImage* anImage)
{
	aRect = NSInsetRect(aRect, -kExtendWidth, -kExtendHeight);
	NSRect contentRect = NSMakeRect(0, 0, NSWidth(aRect), NSHeight(aRect));
	NSWindow* window = [[NSWindow alloc] initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[window setAlphaValue:1];
	[window setBackgroundColor:[NSColor clearColor]];
	[window setExcludedFromWindowsMenu:YES];
	[window setHasShadow:YES];
	[window setIgnoresMouseEvents:YES];
	[window setLevel:NSStatusWindowLevel];
	[window setOpaque:NO];
	[window setReleasedWhenClosed:NO];
	[window useOptimizedDrawing:YES];

	OakPopOutView* aView = [[[OakPopOutView alloc] initWithFrame:contentRect] autorelease];
	[aView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
	aView.contentImage = anImage;
	[[window contentView] addSubview:aView];

	[window setFrame:aRect display:YES];
	[window orderFront:nil];

	[aView startAnimation:nil];
}

static double bounce_curve (double t)
{
	return 1 - sqrt( 1 - pow((1 - fabs(2*t - 1)), 2) );
	// return 1 - fabs( 2 * (1 - (1.0 / (1.0 + exp(-12*t + 6)))) - 1);
}

@implementation OakPopOutView
@synthesize animationStartTime, contentImage;

- (id)initWithFrame:(NSRect)aRect
{
	if(self = [super initWithFrame:aRect])
	{
		double const slowDownFactor = 1; // ([[NSApp currentEvent] modifierFlags] & (NSCommandKeyMask|NSAlternateKeyMask|NSControlKeyMask|NSShiftKeyMask)) == NSShiftKeyMask ? 6 : 1;
		growDuration = kGrowDuration * slowDownFactor;
		fadeDuration = kFadeDuration * slowDownFactor;
	}
	return self;
}

- (void)dealloc
{
	[animationStartTime release];
	[super dealloc];
}

- (void)startAnimation:(id)sender
{
	baseFrame = [[self window] frame];
	self.animationStartTime = [[NSDate date] retain];
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
}

- (void)animationTick:(NSTimer*)aTimer
{
	double const totalDuration = 2*growDuration + fadeDuration;

	CGFloat alpha = 1.0;
	CGFloat grow  = 0.0;

	double t = -[animationStartTime timeIntervalSinceNow];
	if(t > totalDuration)
	{
		[aTimer invalidate];
		[[self window] orderOut:self];
		[[self window] release];
		return;
	}
	else if(t > 2*growDuration)
	{
		t = (t - 2*growDuration) * 1.0/fadeDuration;
		alpha = 0.97 * (1 - OakSlowInOut(t));
	}
	else
	{
		t = t * 1.0/(2*growDuration);
		grow = bounce_curve(t);
	}

	grow = 1 + grow / 2;
	CGFloat w = NSWidth(baseFrame)  * grow;
	CGFloat h = NSHeight(baseFrame) * grow;
	CGFloat x = round(NSMidX(baseFrame) - w/2);
	CGFloat y = round(NSMidY(baseFrame) - h/2);
	[[self window] setFrame:NSMakeRect(x, y, round(w), round(h)) display:YES];
	[[self window] setAlphaValue:alpha];
}

- (BOOL)isFlipped             { return YES; }
- (BOOL)isOpaque              { return NO; }

- (void)drawRect:(NSRect)aRect
{
	[[NSColor clearColor] set];
	NSRectFill(aRect);

	NSBezierPath* roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:kRectXRadius yRadius:kRectYRadius];
	[[NSColor yellowColor] set];
	[roundedRect fill];
	[[NSColor whiteColor] set];
	[roundedRect stroke];

	[contentImage drawAdjustedInRect:NSInsetRect([self bounds], kExtendWidth, kExtendHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];

	[super drawRect:aRect];
}
@end