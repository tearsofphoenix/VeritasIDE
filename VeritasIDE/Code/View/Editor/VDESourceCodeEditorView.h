//
//  VDESourceCodeEditorView.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import <Cocoa/Cocoa.h>

@class XCTextSelectionSymbolInfo;
@class XCDiffComparatorView;
@class XCTextAnnotation;
@class XCTextAnnotationIndicatorAnimation;
@class OakMutableRangeArray;
@class OakRangeArray;
@class VDETextSiderBarView;

@interface VDESourceCodeEditorView : NSTextView
{
    CGFloat _pageGuideWidth;
    NSColor *_pageGuideOutOfBoundsColor;
    NSInteger _pageNumber;
    CGFloat _highlightStartY;
    CGFloat _highlightHeight;
    NSColor *_highlightBaseColor;
    BOOL _observingHighlightColorChangedNotification;
    BOOL _isMouseInsideView;
    BOOL _isDoingBatchEdit;
    NSRange _lastSelectedRangeDuringBatchEdit;
    BOOL _allowsCodeFolding;
    BOOL _showingCodeFocus;
    NSUInteger _oldFocusLocation;
    NSAnimation *_blockAnimation;
    CGPoint _lastMouseMovedLocation;
    NSUInteger _modifierFlagsAtLastSingleMouseDown;
    XCTextSelectionSymbolInfo *_selectionSymbolInfo;
    XCDiffComparatorView *_comparatorView;
    NSRange _foldingHoverRange;
    NSTimer *_foldingHoverTimer;
    CGPoint _foldingHoverLocation;
    XCTextAnnotation *_draggedAnnotation;
    XCTextAnnotationIndicatorAnimation *_annotationIndicatorAnimation;
    NSUInteger _autoHighlightTokenOption;
    CGFloat _autoHighlightTokenDelay;
    NSTimer *_autoHighlightTokenTimer;
    OakMutableRangeArray *_autoHighlightTokenRanges;
    CGFloat _autoHighlightTokenMenuDelay;
    NSTimer *_autoHighlightTokenMenuTimer;
    NSRange _autoHighlightTokenMenuRange;
    CGFloat _autoHighlightTokenMenuAnimationDuration;
    NSTimer *_autoHighlightTokenMenuAnimationTimer;
    CGFloat _autoHighlightTokenMenuAnimationStartTime;
    NSWindow *_autoHighlightTokenWindow;
    BOOL _isTokenizedEditingEnabled;
    OakMutableRangeArray *_tokenizedEditingTokenRanges;
    NSUInteger _tokenizedEditingEditedTokenIndex;
    NSUInteger _tokenizedEditingDeferedOffset;
    NSRange _tokenizedEditingSelectionRange;
    NSColor *_tokenizedEditingTokenColors[4];
    OakRangeArray *_foundRanges;
    NSUInteger _currentFoundRange;
    NSColor *_foundRangesHighlightColor;
    BOOL _animatesCurrentScroll;
    BOOL _disableUpdatingInsertionPointCount;
}

#pragma mark - configuration

+ (void)setTextEditorInsertionPointColor: (NSColor *)color;
+ (NSColor *)textEditorInsertionPointColor;

+ (void)setTextEditorSelectionBackgroundColor: (NSColor *)color;
+ (NSColor *)textEditorSelectionBackgroundColor;

+ (void)setTextEditorBackgroundColor: (NSColor *)color;
+ (NSColor *)textEditorBackgroundColor;

+ (void)setBackgroundStyle:(int)arg1;
+ (int)backgroundStyle;

+ (NSColor *)blockHighlightColor;
+ (void)initialize;

#pragma mark - find range support

- (void)setFoundRangesHighlightColor: (NSColor *)color;

- (void)drawFoundRangesInRange:(NSRange)range;

- (NSUInteger)currentFoundRange;
- (void)setCurrentFoundRange: (NSUInteger)range;

- (void)setFoundRanges: (OakRangeArray *)ranges;
- (id)sidebarView;

- (void)setNeedsDisplayInSidebar: (BOOL)flag;

#pragma mark - fold & unfold

- (void)unfoldAllComments: (id)sender;
- (void)foldAllComments: (id)sender;
- (void)unfoldAllMethods: (id)sender;
- (void)foldAllMethods: (id)sender;
- (void)unfoldRecursive: (id)sender;
- (void)unfold: (id)sender;
- (void)unfoldAll: (id)sender;
- (void)foldSelection: (id)sender;
- (void)foldRecursive: (id)sender;
- (void)fold: (id)sender;

#pragma mark - paseboard support

- (BOOL)readSelectionFromPasteboard: (NSPasteboard *)pasteboard
                               type: (NSString *)type;
- (BOOL)writeSelectionToPasteboard: (NSPasteboard *)pasteboard
                              type: (NSString *)type;

- (BOOL)writeRTFSelectionToPasteboard: (NSPasteboard *)pasteboard;

- (NSArray *)writablePasteboardTypes;

- (void)PBX_balanceParens: (id)arg1;
- (void)PBX_nestLeft: (id)arg1;
- (void)PBX_nestRight: (id)arg1;
- (void)PBX_doUserIndentByNumberOfLevels: (NSInteger)level;
- (void)showMatchingBraceAtLocation: (id)arg1;
- (void)PBX_textViewDidChangeSelection: (id)sender;
- (void)PBX_toggleShowsInvisibleCharacters: (id)sender;
- (void)PBX_toggleShowsControlCharacters: (id)sender;

- (id)         layoutManager: (NSLayoutManager *)layoutManager
shouldUseTemporaryAttributes: (NSDictionary *)attibutes
          forDrawingToScreen: (BOOL)flag
            atCharacterIndex: (NSUInteger)idx
              effectiveRange: (NSRange *)outRange;

- (void)viewWillMoveToWindow: (NSWindow *)window;

#pragma mark - token support

- (void)selectPreviousToken: (id)sender;
- (void)selectNextToken: (id)sender;
- (void)toggleTokenizedEditing: (id)arg1;

- (NSColor *)tokenizedEditingSelectedTokenBackgroundColor;
- (void)setTokenizedEditingSelectedTokenBackgroundColor: (NSColor *)color;

- (NSColor *)tokenizedEditingSelectedTokenBorderColor;
- (void)setTokenizedEditingSelectedTokenBorderColor: (NSColor *)color;

- (NSColor *)tokenizedEditingTokenBackgroundColor;
- (void)setTokenizedEditingTokenBackgroundColor:(NSColor *)color;

- (NSColor *)tokenizedEditingTokenBorderColor;
- (void)setTokenizedEditingTokenBorderColor: (NSColor *)color;

- (NSArray *)tokenizedEditingTokenPathsForCharacterRange:(NSRange)range;
- (NSArray *)tokenPathsForCharacterRange: (NSRange)range
                             displayOnly: (BOOL)arg2;

- (void)textStorage: (NSTextStorage *)textStorage
       didEditRange: (NSRange)range
     changeInLength: (NSInteger)len;

- (void)textStorage: (NSTextStorage *)textStorage
      willEditRange: (NSRange)range
     changeInLength: (NSInteger)len;

- (NSRange)tokenizedEditingSelectionRange;
- (void)setTokenizedEditingSelectionRange: (NSRange)range;

- (OakRangeArray *)tokenizedEditingTokenRanges;

- (BOOL)isTokenizedEditingEnabled;
- (void)setTokenizedEditingEnabled:(BOOL)flag;

- (void)updateTokenizedEditingRanges;

- (NSArray *)tokenizableItemsForRealRange: (NSRange)range;

- (void)scheduleAutoHighlightTokenTimerIfNeeded;
- (void)_autoHighlightTokenWithTimer: (NSTimer *)timer;

- (void)scheduleAutoHighlightTokenMenuTimerIfNeeded;
- (void)_showAutoHighlightTokenMenuWithTimer: (NSTimer *)timer;

- (id)_autoHighlightTokenWindowWithTokenRect: (CGRect)rect;
- (void)scheduleAutoHighlightTokenMenuAnimationTimerIfNeeded;
- (CGRect)_hitTestRectForAutoHighlightTokenWindow: (NSWindow *)window;
- (CGRect)_autoHighlightTokenRectAtPoint:(CGPoint)pos;
- (NSRange)_autoHighlightTokenMenuRangeAtPoint:(CGPoint)pos;
- (void)_animateAutoHighlightTokenMenuWithTimer:(NSTimer *)timer;
- (void)_popUpTokenMenu:(id)sender;
- (BOOL)_isAutoHighlightTokenMenuOverridden;
- (NSMenu *)autoHighlightTokenMenu;
- (void)clearAutoHighlightTokenMenu;
- (void)clearDisplayForAutoHighlightTokens;
- (void)_displayAutoHighlightTokens;
- (CGFloat)autoHighlightTokenMenuDelay;
- (void)setAutoHighlightTokenMenuDelay:(CGFloat)delay;

- (CGFloat)autoHighlightTokenDelay;
- (void)setAutoHighlightTokenDelay:(CGFloat)delay;

- (NSUInteger)autoHighlightTokenOption;
- (void)setAutoHighlightTokenOption:(NSUInteger)option;

- (NSColor *)completionColor;
- (NSColor *)commonCharactersColor;

- (NSRange)completionIndicatorRange;
- (NSRange)liveInlineCommonCharactersRange;

- (BOOL)isInlineCompleting;
- (void)setFoldsFromString:(NSString *)str;

- (NSString *)foldString;
- (NSInteger)_currentLineNumber;
- (NSRange)rangeOfCenterLine;
- (NSRange)visibleRange;
- (void)doingBatchEdit:(BOOL)flag;

- (XCTextAnnotation *)annotationForSubview:(NSView *)subview;

- (XCTextAnnotation *)annotationBeingDragged;

#pragma mark - event handle

- (BOOL)shouldDelayWindowOrderingForEvent: (NSEvent *)event;

- (BOOL)acceptsFirstMouse: (NSEvent *)event;
- (void)cursorUpdate: (NSEvent *)event;
- (void)rightMouseDown: (NSEvent *)event;
- (void)rightMouseUp: (NSEvent *)event;
- (void)mouseDragged: (NSEvent *)event;
- (void)mouseUp: (NSEvent *)event;
- (void)mouseDown: (NSEvent *)event;

- (NSUInteger)modifierFlagsAtLastSingleMouseDown;

- (NSView *)hitTest:(CGPoint)pos;
- (void)scrollWheel: (NSEvent *)event;
- (void)_toolTipTimer;
- (void)mouseExited: (NSEvent *)event;
- (void)mouseEntered: (NSEvent *)event;
- (void)mouseMoved: (NSEvent *)event;
- (void)_mouseInside: (NSEvent *)event;
- (void)removeFromSuperview;
- (void)viewDidMoveToWindow;
- (void)animation:(id)arg1
didReachProgressMark:(float)mark;

- (void)animationDidEnd:(id)arg1;
- (void)animationDidStop:(id)arg1;
- (BOOL)animationShouldStart:(id)arg1;

- (void)stopBlockHighlighting;
- (void)startBlockHighlighting;

- (void)focusLocationMayHaveChanged: (id)sender;
- (void)toggleCodeFocus:(id)sender;
- (void)_drawViewBackgroundInRect: (CGRect)rect;
- (void)_drawTokensInRect: (CGRect)rect;
- (void)drawTextAnnotationInRect: (CGRect)rect;
- (NSInteger)_drawRoundedBackgroundForItem: (id)arg1
                               dynamicItem: (id)arg2;

- (id)_roundedRect: (CGRect)rect
        withRadius: (CGFloat)radius;

- (NSUInteger)_drawBlockBackground: (CGRect)rect
                        atLocation: (NSUInteger)idx
                           forItem: (id)item
                       dynamicItem: (id)arg4;

- (CGFloat)_grayLevelForDepth:(NSInteger)depthLevel;
- (NSColor *)alternateColor;

- (void)setFoldingHoverRange:(NSRange)range;
- (NSRange)foldingHoverRange;

- (void)setNeedsDisplayInRect: (CGRect)rect
        avoidAdditionalLayout: (BOOL)flag;

- (void)drawRect:(CGRect)rect;
- (void)_drawRect:(CGRect)rect
             clip: (BOOL)flag;
- (void)_drawOverlayRect:(CGRect)rect;

- (NSArray *)visibleAnnotations;

- (BOOL)shouldDrawAnnotation: (XCTextAnnotation *)annotation;

- (NSUInteger)_charLocationForMousePoint:(CGPoint)pos;

- (void)setShowsFoldingSidebar:(BOOL)flag;
- (BOOL)showsFoldingSidebar;

- (void)showAnnotationIndicatorForAnnotation: (XCTextAnnotation *)annotation;
- (NSArray *)annotationsForLineNumberRange:(NSRange)range;

- (void)getParagraphRect: (CGRect *)outRect1
           firstLineRect: (CGRect *)outRect2
           forLineNumber: (NSUInteger)lineNumber;

- (NSRange)lineNumberRangeForBoundingRect: (CGRect)rect;
- (NSUInteger)lineNumberForPoint:(CGPoint)pos;
- (void)breakUndoCoalescing;
- (void)scrollRangeToVisible: (NSRange)range
                     animate: (BOOL)flag;
- (void)insertText: (NSString *)text
  replacementRange: (NSRange)range;

- (BOOL)allowsCodeFolding;
- (void)setAllowsCodeFolding:(BOOL)flag;

- (void)setTextStorage: (NSTextStorage *)textStorage;
- (void)setTextStorage: (NSTextStorage *)textStorage
         keepOldLayout: (BOOL)flag;

- (NSTextStorage *)textStorage;

#pragma mark -  life cycle

- (void)dealloc;
- (id)initWithCoder: (NSCoder *)coder;
- (id)initWithFrame: (CGRect)rect
      textContainer: (NSTextContainer *)textContainer;

- (id)init;
- (void)_commonInit;
- (NSColor *)backgroundColor;
- (void)doCommandBySelector: (SEL)sel;

#pragma mark - accessibility

- (CGRect)_accessibilityBoundsOfChild: (id)arg1;
- (id)accessibilityStyleRangeForIndexAttributeForParameter:(id)arg1;
- (id)accessibilityAttributedStringForRangeAttributeForParameter:(id)arg1;
- (id)accessibilityRTFForRangeAttributeForParameter:(id)arg1;
- (id)accessibilityBoundsForRangeAttributeForParameter:(id)arg1;
- (id)accessibilityRangeForIndexAttributeForParameter:(id)arg1;
- (id)accessibilityStringForRangeAttributeForParameter:(id)arg1;
- (id)accessibilitySharedTextUIElementsAttribute;
- (void)accessibilitySetVisibleCharacterRangeAttribute:(id)arg1;
- (id)accessibilityNumberOfCharactersAttribute;
- (void)accessibilitySetSelectedTextRangesAttribute:(id)arg1;
- (id)accessibilitySelectedTextRangesAttribute;
- (void)accessibilitySetSelectedTextRangeAttribute:(id)arg1;
- (void)accessibilitySetValueAttribute:(id)arg1;
- (id)accessibilityValueAttribute;
- (id)accessibilityTextLinkAtIndex:(NSUInteger)arg1;
- (id)accessibilityTextLinks;
- (id)accessibilityAttachmentAtIndex:(NSUInteger)arg1;
- (NSUInteger)accessibilityIndexForAttachment:(id)arg1;
- (id)accessibilityAttachments;
- (NSRange)accessibilitySharedCharacterRange;
- (id)accessibilitySharedTextViews;
- (NSRange)accessibilityStyleRangeForCharacterIndex:(NSUInteger)arg1;
- (id)accessibilityAXAttributedStringForCharacterRange:(NSRange)arg1 parent:(id)arg2;
- (id)accessibilityRTFForCharacterRange:(NSRange)arg1;
- (CGRect)accessibilityBoundsForCharacterRange:(NSRange)arg1;
- (NSRange)accessibilityCharacterRangeForPosition:(CGPoint)arg1;
- (NSRange)accessibilityCharacterRangeForLineNumber:(NSUInteger)arg1;
- (NSUInteger)accessibilityLineNumberForCharacterIndex:(NSUInteger)arg1;
- (NSUInteger)accessibilityInsertionPointLineNumber;
- (void)accessibilitySetVisibleCharacterRange:(NSRange)arg1;
- (NSRange)accessibilityVisibleCharacterRange;
- (void)accessibilitySetSelectedRange:(NSRange)arg1;
- (NSRange)accessibilitySelectedRange;
- (void)accessibilitySetSelectedText:(id)arg1;
- (id)accessibilitySelectedText;


- (void)setTypingAttributes: (NSDictionary *)attrs;
- (void)viewDidEndLiveResize;
- (void)viewWillStartLiveResize;

- (void)_scrollRangeToVisible: (NSRange)range
                  forceCenter: (BOOL)flag;
- (void)_centeredScrollRectToVisible: (CGRect)rect
                         forceCenter: (BOOL)flag;

- (void)_adjustedCenteredScrollRectToVisible: (CGRect)rect
                                 forceCenter: (BOOL)flag;
- (void)_setFrameSize: (CGSize)size
          forceScroll: (BOOL)flag;

- (BOOL)_ensureLayoutCompleteForVisibleRectWithExtension:(BOOL)flag;
- (void)_ensureLayoutCompleteToEndOfCharacterRange:(NSRange)range;
- (void)_sizeDownIfPossible;
- (void)setMarkedText: (NSString *)str
        selectedRange: (NSRange)range;
- (BOOL)performDragOperation: (id<NSDraggingInfo>)info;

- (void)_fixDragAndDropCharRangesForChangeInRanges: (OakRangeArray *)ranges
                                replacementStrings: (NSString *)strs;
- (void)_userReplaceRange: (NSRange)range
               withString: (NSString *)str;
- (void)didChangeText;

- (BOOL)shouldChangeTextInRanges: (NSArray *)affectedRanges
              replacementStrings: (NSArray *)replacementStrings;

- (void)showFindIndicatorForRange:(NSRange)range;
- (void)_showFindIndicator;

- (void)scrollRangeToVisible:(NSRange)range;
- (BOOL)scrollRectToVisible:(CGRect)rect;
- (void)scrollPoint:(CGPoint)pos;

- (void)drawInsertionPointInRect: (CGRect)rect
                           color: (NSColor *)color
                        turnedOn: (BOOL)flag;
- (void)updateInsertionPointStateAndRestartTimer:(BOOL)flag;

- (void)setSelectedRanges: (OakRangeArray *)ranges
                 affinity: (NSUInteger)arg2
           stillSelecting: (BOOL)flag;

- (OakRangeArray *)selectedRanges;
- (void)setSelectedRange:(NSRange)range;
- (NSRange)selectedRange;

- (void)selectAll: (id)sender;

- (void)becomeMainWindow;
- (void)resignKeyWindow;
- (void)becomeKeyWindow;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)_invalidateDisplayForViewStatusChange;
- (void)resetCursorRects;
- (void)_invalidateAllRevealovers;
- (void)indentSelectionIfIndentable: (id)arg1;
- (void)indentSelection: (id)arg1;

@end
