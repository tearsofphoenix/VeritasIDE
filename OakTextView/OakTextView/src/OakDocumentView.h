#import "GutterView.h"
#import "OakTextView.h"
#import <document/document.h>


@class OTVStatusBar;

@interface OakDocumentView : NSView <GutterViewDelegate, GutterViewColumnDataSource, GutterViewColumnDelegate>
{
	OBJC_WATCH_LEAKS(OakDocumentView);

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
	document::OakDocument * document;
	document::document_t::callback_t* callback;

	NSMutableArray* topAuxiliaryViews;
	NSMutableArray* bottomAuxiliaryViews;

	IBOutlet NSPanel* tabSizeSelectorPanel;
}
@property (nonatomic, readonly) OakTextView* textView;
@property (nonatomic, assign) document::OakDocument *  document;
- (IBAction)toggleLineNumbers:(id)sender;
- (IBAction)takeThemeUUIDFrom:(id)sender;

- (void)setThemeWithUUID:(NSString*)themeUUID;

- (void)addAuxiliaryView:(NSView*)aView atEdge:(NSRectEdge)anEdge;
- (void)removeAuxiliaryView:(NSView*)aView;
@end
