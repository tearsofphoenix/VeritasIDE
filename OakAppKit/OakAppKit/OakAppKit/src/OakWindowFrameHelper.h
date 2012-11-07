

@interface OakWindowFrameHelper : NSObject
{
	NSWindow* window;
	NSString* autosaveName;
	Class windowDelegateClass;
}

+ (OakWindowFrameHelper*)windowFrameHelperWithWindow:(NSWindow*)aWindow;

@end
