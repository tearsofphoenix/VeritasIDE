
#import <OakAppKit/OakStatusBar.h>
#import <OakFoundation/OakFoundation.h>

@interface OTVStatusBar : OakStatusBar
{
	OakTextRange * caretPosition;
	NSString* grammarName;
	NSString* symbolName;
	BOOL isMacroRecording;
	BOOL softTabs;
	int32_t tabSize;

	id delegate;

	NSImage* pulsedRecordingIndicator;
	NSTimer* recordingTimer;
	CGFloat recordingTime;
}
- (void)setCaretPosition:(NSString *)range;
@property (nonatomic, copy)   NSString* grammarName;
@property (nonatomic, copy)   NSString* symbolName;
@property (nonatomic, assign) BOOL isMacroRecording;
@property (nonatomic, assign) BOOL softTabs;
@property (nonatomic, assign) int32_t tabSize;

@property (nonatomic, assign) id delegate;
@end
