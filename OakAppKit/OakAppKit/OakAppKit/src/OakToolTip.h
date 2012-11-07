#import <oak/misc.h>


@interface OakToolTip : NSWindow
{
	NSTextField* field;
	NSTimer* animationTimer;
	NSDate* animationStart;

	NSDate* didOpenAtDate; // ignore mouse moves for the next second
	NSPoint mousePositionWhenOpened;
	BOOL enforceMouseThreshold;
}

- (void)setEnforceMouseThreshold: (BOOL)flag;

- (void)setFont: (NSFont *)aFont;

- (void)setStringValue: (NSString*)aString;

- (void)showAtLocation: (NSPoint)aPoint
             forScreen: (NSScreen*)aScreen;
@end

extern void OakShowToolTip (NSString* msg, NSPoint location);
