#import "NSScreen+Additions.h"

@implementation NSScreen (RestrainFrames)

+ (NSScreen* )screenWithFrame: (NSRect)rect
{
    NSMutableDictionary *rank = [NSMutableDictionary dictionary];

	for(NSScreen* scr in [NSScreen screens])
	{
		NSRect r = NSIntersectionRect([scr visibleFrame], rect);
        [rank setObject: scr
                 forKey: @(- NSWidth(r) * NSHeight(r))];
	}

    NSArray *allKeys = [rank allKeys];
    
	if([allKeys count] == 0 || [[allKeys objectAtIndex: 0] floatValue] == 0.0)
    {
			return [NSScreen mainScreen];
	}else
    {
        return [rank objectForKey: [allKeys objectAtIndex: 0]];
    }
}

- (NSRect)restrainFrameToVisibleScreen:(NSRect)aFrame
{
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"OakScreenDisableWindowRestraining"])
		return aFrame;

	NSRect r = [self visibleFrame];
	CGFloat scrX0 = NSMinX(r), scrX1 = NSMaxX(r);
	CGFloat scrY0 = NSMinY(r), scrY1 = NSMaxY(r);

	CGFloat x0 = MAX(NSMinX(aFrame), scrX0);
	CGFloat x1 = MIN(NSMaxX(aFrame), scrX1);
	CGFloat y0 = MAX(NSMinY(aFrame), scrY0);
	CGFloat y1 = MIN(NSMaxY(aFrame), scrY1);

	CGFloat extra_width = NSWidth(aFrame) - (x1 - x0);
	CGFloat extra_height = NSHeight(aFrame) - (y1 - y0);

	x0 = MAX(x0 - extra_width, scrX0);
	x1 = MIN(x1 + extra_width, scrX1);
	y0 = MAX(y0 - extra_height, scrY0);
	y1 = MIN(y1 + extra_height, scrY1);

	return NSIntegralRect(NSMakeRect(x0, y0, MAX((CGFloat)200, x1 - x0), MAX((CGFloat)200, y1 - y0)));
}
@end
