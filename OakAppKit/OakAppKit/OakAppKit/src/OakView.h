
enum
{
    OakViewApplicationIsActiveMask  = 1 << 0,
    OakViewWindowIsMainMask         = 1 << 1,
    OakViewWindowIsKeyMask          = 1 << 2,
    OakViewViewIsFirstResponderMask = 1 << 3,
};

typedef NSInteger OakViewKeyState;

@interface OakView : NSView
{
	BOOL isFirstResponder;
}

@property (nonatomic) OakViewKeyState keyState;

@end
