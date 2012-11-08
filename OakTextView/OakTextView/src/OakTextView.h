#import "GutterView.h"
#import <OakAppKit/OakView.h>

extern int32_t const NSWrapColumnWindowWidth;
extern int32_t const NSWrapColumnAskUser;
extern NSString* const kUserDefaultsDisableAntiAliasKey;

@class OakTextView;
@class OakTimer;
@class OakChoiceMenu;
@class OakDocument;
@class OakTheme;
@class OakEditor;
@class OakLayout;
@class OakSelectionIndex;
@class OakSelectionRangeArray;
@class OakScopeContext;
@class OakBundleItem;

struct buffer_refresh_callback_t;

enum folding_state_t { kFoldingNone, kFoldingTop, kFoldingCollapsed, kFoldingBottom };

@protocol OakTextViewDelegate <NSObject>

@optional

- (NSString*)scopeAttributes;

@end

@interface OakTextView : OakView <NSTextInput, NSTextFieldDelegate>
{
	OakDocument * document;
	OakTheme *theme;
	NSString * fontName;
	CGFloat fontSize;
	BOOL antiAlias;
	BOOL showInvisibles;
	OakEditor *editor;
	OakLayout *layout;
	NSUInteger refreshNestCount;
	buffer_refresh_callback_t* callback;

	int32_t wrapColumn;

	BOOL hideCaret;
	NSTimer* blinkCaretTimer;

	NSImage* spellingDotImage;
	NSImage* foldingDotsImage;

	// =================
	// = Mouse Support =
	// =================

	NSCursor* ibeamCursor;

	NSPoint mouseDownPos;
	OakSelectionIndex *mouseDownIndex;
	NSInteger mouseDownModifierFlags;
	NSInteger mouseDownClickCount;

	OakTimer* initiateDragTimer;
	OakTimer* dragScrollTimer;
	NSDate* optionDownDate;
	BOOL showDragCursor;
	BOOL showColumnSelectionCursor;
	BOOL ignoreMouseDown;  // set when the mouse down is the same event which caused becomeFirstResponder:
	BOOL delayMouseDown; // set when mouseUp: should process lastMouseDownEvent

	// ===============
	// = Drag’n’drop =
	// ===============

	OakSelectionIndex *dropPosition;
	OakSelectionRangeArray * markedRanges;
	OakSelectionRangeArray * pendingMarkedRanges;

	NSString* selectionString;
	BOOL isUpdatingSelection;

	NSMutableArray* macroRecordingArray;

	// ======================
	// = Incremental Search =
	// ======================

	NSViewController* liveSearchViewController;
	NSString* liveSearchString;
	OakSelectionRangeArray * liveSearchAnchor;
	OakSelectionRangeArray * liveSearchRanges;

	// ===================
	// = Snippet Choices =
	// ===================

	OakChoiceMenu* choiceMenu;
	NSMutableArray *choiceVector;
}
- (void)setDocument: (OakDocument * )aDocument;

@property (nonatomic, assign) id <OakTextViewDelegate>      delegate;
@property (nonatomic, assign) OakTheme *               theme;
@property (nonatomic, retain) NSCursor*                     ibeamCursor;
@property (nonatomic, retain) NSFont*                       font;
@property (nonatomic, assign) BOOL                          antiAlias;
@property (nonatomic, assign) NSUInteger                        tabSize;
@property (nonatomic, assign) BOOL                          showInvisibles;
@property (nonatomic, assign) BOOL                          softWrap;
@property (nonatomic, assign) BOOL                          softTabs;
@property (nonatomic, readonly) BOOL                        continuousIndentCorrections;

@property (nonatomic, readonly) BOOL                        hasMultiLineSelection;
@property (nonatomic, readonly) BOOL                        hasSelection;
@property (nonatomic, retain) NSString*                     selectionString;

@property (nonatomic, assign) BOOL                          isMacroRecording;

- (GVLineRecord )lineRecordForPosition:(CGFloat)yPos;
- (GVLineRecord )lineFragmentForLine:(NSUInteger)aLine column:(NSUInteger)aColumn;

- (NSPoint)positionForWindowUnderCaret;
- (OakScopeContext * )scopeContext;
- (folding_state_t)foldingStateForLine:(NSUInteger)lineNumber;

- (IBAction)toggleMacroRecording:(id)sender;
- (IBAction)toggleFoldingAtLine:(NSUInteger)lineNumber recursive:(BOOL)flag;
- (IBAction)toggleShowInvisibles:(id)sender;

- (void)performBundleItem:(OakBundleItem *)anItem;
@end
