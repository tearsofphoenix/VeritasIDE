

@interface OakZoomingIcon : NSWindow
{
@private
	NSRect startFrame;
	NSDate* startTime;
	NSTimeInterval duration;
	NSTimer* animationTimer;
}

+ (void)zoomIcon: (NSImage*)icon
        fromRect: (NSRect)aRect;

@end
