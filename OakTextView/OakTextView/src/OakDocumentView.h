#import "GutterView.h"
#import "OakTextView.h"

@class OTVStatusBar;

@interface OakDocumentView : NSView <GutterViewDelegate, GutterViewColumnDataSource, GutterViewColumnDelegate>
{
	NSScrollView* gutterScrollView;
	GutterView* gutterView;
	NSColor* gutterDividerColor;
	NSDictionary* gutterImages;
	NSDictionary* gutterHoverImages;
	NSDictionary* gutterPressedImages;

	NSBox* gutterDividerView;

	NSScrollView* textScrollView;
	OakTextView* textView;
	OTVStatusBar* statusBar;
	OakDocument * document;
	id callback;

	NSMutableArray* topAuxiliaryViews;
	NSMutableArray* bottomAuxiliaryViews;

	IBOutlet NSPanel* tabSizeSelectorPanel;
}

@property (nonatomic, readonly) OakTextView* textView;
@property (nonatomic, assign) OakDocument *  document;
- (IBAction)toggleLineNumbers:(id)sender;
- (IBAction)takeThemeUUIDFrom:(id)sender;

- (void)setThemeWithUUID:(NSString*)themeUUID;

- (void)addAuxiliaryView:(NSView*)aView atEdge:(NSRectEdge)anEdge;
- (void)removeAuxiliaryView:(NSView*)aView;
@end
