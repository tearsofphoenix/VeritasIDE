#import <oak/misc.h>

extern NSUInteger const OakViewApplicationIsActiveMask;
extern NSUInteger const OakViewWindowIsMainMask;
extern NSUInteger const OakViewWindowIsKeyMask;
extern NSUInteger const OakViewViewIsFirstResponderMask;

@interface OakView : NSView
{
	BOOL isFirstResponder;
	NSUInteger keyState;
}
@property (nonatomic, assign) NSUInteger keyState;
@end
