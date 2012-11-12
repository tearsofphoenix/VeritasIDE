//
//  XCTextView.m
//  XCodeEdit
//
//  Created by tearsofphoenix on 12-11-10.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCTextView.h"

@implementation XCTextView

#pragma mark - class configuration

static NSColor *s_VDETextEditorInsertionPointColor = nil;

+ (void)setTextEditorInsertionPointColor: (NSColor *)color
{
    if (s_VDETextEditorInsertionPointColor != color)
    {
        [s_VDETextEditorInsertionPointColor release];
        s_VDETextEditorInsertionPointColor = [color retain];
    }
}

+ (NSColor *)textEditorInsertionPointColor
{
    return s_VDETextEditorInsertionPointColor;
}

static NSColor *s_VDETextEditorSelectionBackgroundColor = nil;

+ (void)setTextEditorSelectionBackgroundColor: (NSColor *)color
{
    if (s_VDETextEditorSelectionBackgroundColor != color)
    {
        [s_VDETextEditorSelectionBackgroundColor release];
        s_VDETextEditorSelectionBackgroundColor = [color retain];
    }
}

+ (NSColor *)textEditorSelectionBackgroundColor
{
    return s_VDETextEditorSelectionBackgroundColor;
}

static NSColor *s_VDETextEditorBackgroundColor = nil;

+ (void)setTextEditorBackgroundColor: (NSColor *)color
{
    if (s_VDETextEditorBackgroundColor != color)
    {
        [s_VDETextEditorBackgroundColor release];
        s_VDETextEditorBackgroundColor = [color retain];
    }
}

+ (NSColor *)textEditorBackgroundColor
{
    return s_VDETextEditorBackgroundColor;
}

static int s_VDEBackgroundStyle = 0;

+ (void)setBackgroundStyle:(int)arg1
{
    if (s_VDEBackgroundStyle != arg1)
    {
        s_VDEBackgroundStyle = arg1;
    }
}

+ (int)backgroundStyle
{
    return s_VDEBackgroundStyle;
}

+ (NSColor *)blockHighlightColor
{
    return [NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00];
}

+ (void)initialize
{
    [self setTextEditorBackgroundColor: [NSColor whiteColor]];
    [self setTextEditorInsertionPointColor: [NSColor grayColor]];
    [self setTextEditorSelectionBackgroundColor: [NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00]];
    
    [self setBackgroundStyle: 1];
}

#pragma mark - life cycle

- (void)dealloc
{
    [super dealloc];
    
}

- (id)initWithCoder: (NSCoder *)coder
{
    if ((self = [super initWithCoder: coder]))
    {
        [self _commonInit];
    }
    
    return self;
}

- (id)initWithFrame: (CGRect)rect
      textContainer: (NSTextContainer *)textContainer
{
    if ((self = [super initWithFrame: rect
                       textContainer: textContainer]))
    {
        [self _commonInit];
    }
    
    return self;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self _commonInit];
    }
    
    return self;
}

- (void)_commonInit
{
    
}

- (NSColor *)backgroundColor
{
    return [NSColor whiteColor];
}

#pragma mark - find range support

- (void)setFoundRangesHighlightColor: (NSColor *)color
{
    if (_foundRangesHighlightColor != color)
    {
        [_foundRangesHighlightColor release];
        _foundRangesHighlightColor = [color retain];
    }
}

- (void)drawFoundRangesInRange:(NSRange)range
{
    
}

- (NSUInteger)currentFoundRange
{
    return _currentFoundRange;
}

- (void)setCurrentFoundRange: (NSUInteger)range
{
    if (_currentFoundRange != range)
    {
        _currentFoundRange = range;
    }
}

- (void)setFoundRanges: (OakRangeArray *)ranges
{
    if(_foundRanges != ranges)
    {
        [_foundRanges release];
        _foundRanges = [ranges retain];
    }
}

- (id)sidebarView
{
    
}

- (void)setNeedsDisplayInSidebar: (BOOL)flag
{
    
}

#pragma mark - fold & unfold

- (void)unfoldAllComments: (id)sender
{
    
}

- (void)foldAllComments: (id)sender
{
    
}

- (void)unfoldAllMethods: (id)sender
{
    
}

- (void)foldAllMethods: (id)sender
{
    
}

- (void)unfoldRecursive: (id)sender
{
    
}

- (void)unfold: (id)sender
{
    
}

- (void)unfoldAll: (id)sender
{
    
}

- (void)foldSelection: (id)sender
{
    
}

- (void)foldRecursive: (id)sender
{
    
}

- (void)fold: (id)sender
{
    
}

#pragma mark - paseboard support

- (BOOL)readSelectionFromPasteboard: (NSPasteboard *)pasteboard
                               type: (NSString *)type
{
    
}

- (BOOL)writeSelectionToPasteboard: (NSPasteboard *)pasteboard
                              type: (NSString *)type
{
    
}

- (BOOL)writeRTFSelectionToPasteboard: (NSPasteboard *)pasteboard
{
    
}

- (NSArray *)writablePasteboardTypes
{
    
}

- (void)PBX_balanceParens: (id)arg1
{
    
}
- (void)PBX_nestLeft: (id)arg1
{
    
}
- (void)PBX_nestRight: (id)arg1
{
    
}
- (void)PBX_doUserIndentByNumberOfLevels: (NSInteger)level
{
    
}
- (void)showMatchingBraceAtLocation: (id)arg1
{
    
}
- (void)PBX_textViewDidChangeSelection: (id)sender
{
    
}
- (void)PBX_toggleShowsInvisibleCharacters: (id)sender
{
    
}
- (void)PBX_toggleShowsControlCharacters: (id)sender
{
    
}

- (id)layoutManager: (NSLayoutManager *)layoutManager
shouldUseTemporaryAttributes: (NSDictionary *)attibutes
 forDrawingToScreen: (BOOL)flag
   atCharacterIndex: (NSUInteger)idx
     effectiveRange: (NSRange *)outRange
{
}

- (void)viewWillMoveToWindow: (NSWindow *)window
{
    
}


- (void)selectPreviousToken: (id)sender
{
    
}

- (void)selectNextToken: (id)sender
{
    
}

- (void)toggleTokenizedEditing: (id)arg1
{
    
}

- (NSColor *)tokenizedEditingSelectedTokenBackgroundColor
{
    return _tokenizedEditingTokenColors[0];
}

- (void)setTokenizedEditingSelectedTokenBackgroundColor: (NSColor *)color
{
    if (_tokenizedEditingTokenColors[0] != color)
    {
        [_tokenizedEditingTokenColors[0] release];
        _tokenizedEditingTokenColors[0] = [color retain];
    }
}

- (NSColor *)tokenizedEditingSelectedTokenBorderColor
{
    return _tokenizedEditingTokenColors[1];
}

- (void)setTokenizedEditingSelectedTokenBorderColor: (NSColor *)color
{
    if (_tokenizedEditingTokenColors[1] != color)
    {
        [_tokenizedEditingTokenColors[1] release];
        _tokenizedEditingTokenColors[1] = [color retain];
    }
}

- (NSColor *)tokenizedEditingTokenBackgroundColor
{
    return _tokenizedEditingTokenColors[2];
}

- (void)setTokenizedEditingTokenBackgroundColor:(NSColor *)color
{
    if (_tokenizedEditingTokenColors[2] != color)
    {
        [_tokenizedEditingTokenColors[2] release];
        _tokenizedEditingTokenColors[2] = [color retain];
    }
}

- (NSColor *)tokenizedEditingTokenBorderColor
{
    return _tokenizedEditingTokenColors[3];
}

- (void)setTokenizedEditingTokenBorderColor: (NSColor *)color
{
    if (_tokenizedEditingTokenColors[3] != color)
    {
        [_tokenizedEditingTokenColors[3] release];
        _tokenizedEditingTokenColors[3] = [color retain];
    }
}

- (NSArray *)tokenizedEditingTokenPathsForCharacterRange: (NSRange)range
{
    
}

- (NSArray *)tokenPathsForCharacterRange: (NSRange)range
                             displayOnly: (BOOL)arg2
{
    
}

- (void)textStorage: (NSTextStorage *)textStorage
       didEditRange: (NSRange)range
     changeInLength: (NSInteger)len
{
    
}

- (void)textStorage: (NSTextStorage *)textStorage
      willEditRange: (NSRange)range
     changeInLength: (NSInteger)len
{
    
}

- (NSRange)tokenizedEditingSelectionRange
{
    return _tokenizedEditingSelectionRange;
}

- (void)setTokenizedEditingSelectionRange: (NSRange)range
{
    if (!NSEqualRanges(_tokenizedEditingSelectionRange, range))
    {
        _tokenizedEditingSelectionRange = range;
    }
}

- (OakRangeArray *)tokenizedEditingTokenRanges
{
    
}

- (BOOL)isTokenizedEditingEnabled
{
    return _isTokenizedEditingEnabled;
}

- (void)setTokenizedEditingEnabled:(BOOL)flag
{
    if (_isTokenizedEditingEnabled != flag)
    {
        _isTokenizedEditingEnabled = flag;
    }
}

- (void)updateTokenizedEditingRanges
{
    
}

- (NSArray *)tokenizableItemsForRealRange: (NSRange)range
{
    
}

- (void)scheduleAutoHighlightTokenTimerIfNeeded
{
    if (!_autoHighlightTokenTimer)
    {
        _autoHighlightTokenTimer = [NSTimer scheduledTimerWithTimeInterval: _autoHighlightTokenDelay
                                                                    target: self
                                                                  selector: @selector(_autoHighlightTokenWithTimer:)
                                                                  userInfo: nil
                                                                   repeats: NO];
    }
}

- (void)_autoHighlightTokenWithTimer: (NSTimer *)timer
{
    _autoHighlightTokenTimer = nil;
    
}

- (void)scheduleAutoHighlightTokenMenuTimerIfNeeded
{
    if (!_autoHighlightTokenMenuTimer)
    {
        _autoHighlightTokenMenuTimer = [NSTimer scheduledTimerWithTimeInterval: _autoHighlightTokenMenuDelay
                                                                        target: self
                                                                      selector: @selector(_showAutoHighlightTokenMenuWithTimer:)
                                                                      userInfo: nil
                                                                       repeats: NO];
    }
}

- (void)_showAutoHighlightTokenMenuWithTimer: (NSTimer *)timer
{
    _autoHighlightTokenMenuTimer = nil;
}

- (id)_autoHighlightTokenWindowWithTokenRect: (CGRect)rect
{
    
}

- (void)scheduleAutoHighlightTokenMenuAnimationTimerIfNeeded
{
    
}
- (CGRect)_hitTestRectForAutoHighlightTokenWindow: (NSWindow *)window
{
    
}
- (CGRect)_autoHighlightTokenRectAtPoint:(CGPoint)pos
{
    
}
- (NSRange)_autoHighlightTokenMenuRangeAtPoint:(CGPoint)pos
{
    
}
- (void)_animateAutoHighlightTokenMenuWithTimer:(NSTimer *)timer
{
    
}
- (void)_popUpTokenMenu:(id)sender
{
    
}
- (BOOL)_isAutoHighlightTokenMenuOverridden
{
    
}
- (NSMenu *)autoHighlightTokenMenu
{
    
}
- (void)clearAutoHighlightTokenMenu
{
    
}
- (void)clearDisplayForAutoHighlightTokens
{
    
}
- (void)_displayAutoHighlightTokens
{
    
}
- (CGFloat)autoHighlightTokenMenuDelay
{
    return _autoHighlightTokenMenuDelay;
}
- (void)setAutoHighlightTokenMenuDelay:(CGFloat)delay
{
    if (_autoHighlightTokenMenuDelay != delay)
    {
        _autoHighlightTokenMenuDelay = delay;
    }
}

- (CGFloat)autoHighlightTokenDelay
{
    return _autoHighlightTokenDelay;
}

- (void)setAutoHighlightTokenDelay:(CGFloat)delay
{
    if (_autoHighlightTokenDelay != delay)
    {
        _autoHighlightTokenDelay = delay;
    }
}

- (NSUInteger)autoHighlightTokenOption
{
    return _autoHighlightTokenOption;
}

- (void)setAutoHighlightTokenOption:(NSUInteger)option
{
    if (_autoHighlightTokenOption != option)
    {
        _autoHighlightTokenOption = option;
    }
}

- (NSColor *)completionColor
{
    return [NSColor yellowColor];
}

- (NSColor *)commonCharactersColor
{
    return [NSColor blackColor];
}

- (NSRange)completionIndicatorRange
{
    
}

- (NSRange)liveInlineCommonCharactersRange
{
    
}

- (BOOL)isInlineCompleting
{
}
- (void)setFoldsFromString:(NSString *)str
{
    
}

- (NSString *)foldString
{
}

- (NSInteger)_currentLineNumber
{
    
}
- (NSRange)rangeOfCenterLine
{
    
}
- (NSRange)visibleRange
{
    
}
- (void)doingBatchEdit:(BOOL)flag
{
    
}

- (XCTextAnnotation *)annotationForSubview:(NSView *)subview
{
    
}

- (XCTextAnnotation *)annotationBeingDragged
{
    
}

#pragma mark - event handle

- (BOOL)shouldDelayWindowOrderingForEvent: (NSEvent *)event
{
    
}

- (BOOL)acceptsFirstMouse: (NSEvent *)event
{
    
}
- (void)cursorUpdate: (NSEvent *)event
{
    
}
- (void)rightMouseDown: (NSEvent *)event
{
    
}
- (void)rightMouseUp: (NSEvent *)event
{
    
}
- (void)mouseDragged: (NSEvent *)event
{
    
}
- (void)mouseUp: (NSEvent *)event
{
    
}
- (void)mouseDown: (NSEvent *)event
{
    
}

- (NSUInteger)modifierFlagsAtLastSingleMouseDown
{
    
}

- (NSView *)hitTest:(CGPoint)pos
{
    
}
- (void)scrollWheel: (NSEvent *)event
{
    
}
- (void)_toolTipTimer
{
    
}
- (void)mouseExited: (NSEvent *)event
{
    
}
- (void)mouseEntered: (NSEvent *)event
{
    
}
- (void)mouseMoved: (NSEvent *)event
{
    
}
- (void)_mouseInside: (NSEvent *)event
{
    
}
- (void)removeFromSuperview
{
    
}
- (void)viewDidMoveToWindow
{
    
}
- (void)   animation: (id)arg1
didReachProgressMark: (float)mark
{
    
}

- (void)animationDidEnd:(id)arg1
{
    
}
- (void)animationDidStop:(id)arg1
{
    
}
- (BOOL)animationShouldStart:(id)arg1
{
    
}

- (void)stopBlockHighlighting
{
    
}
- (void)startBlockHighlighting
{
    
}

- (void)focusLocationMayHaveChanged: (id)sender
{
    
}
- (void)toggleCodeFocus:(id)sender
{
    
}
- (void)_drawViewBackgroundInRect: (CGRect)rect
{
    
}
- (void)_drawTokensInRect: (CGRect)rect
{
    
}
- (void)drawTextAnnotationInRect: (CGRect)rect
{
    
}
- (NSInteger)_drawRoundedBackgroundForItem: (id)arg1
                               dynamicItem: (id)arg2
{
    
}

- (id)_roundedRect: (CGRect)rect
        withRadius: (CGFloat)radius
{
    
}

- (NSUInteger)_drawBlockBackground: (CGRect)rect
                        atLocation: (NSUInteger)idx
                           forItem: (id)item
                       dynamicItem: (id)arg4
{
    
}

- (CGFloat)_grayLevelForDepth:(NSInteger)depthLevel
{
    
}
- (NSColor *)alternateColor
{
    
}

- (void)setFoldingHoverRange:(NSRange)range
{
    if (!NSEqualRanges(_foldingHoverRange, range))
    {
        _foldingHoverRange = range;
    }
}
- (NSRange)foldingHoverRange
{
    return _foldingHoverRange;
}

- (void)setNeedsDisplayInRect: (CGRect)rect
        avoidAdditionalLayout: (BOOL)flag
{
    
}

- (void)drawRect:(CGRect)rect
{
    
}
- (void)_drawRect:(CGRect)rect
             clip: (BOOL)flag
{
    
}
- (void)_drawOverlayRect:(CGRect)rect
{
    
}

- (NSArray *)visibleAnnotations
{
    
}

- (BOOL)shouldDrawAnnotation: (XCTextAnnotation *)annotation
{
    
}

- (NSUInteger)_charLocationForMousePoint:(CGPoint)pos
{
    
}

- (void)setShowsFoldingSidebar:(BOOL)flag
{
    
}
- (BOOL)showsFoldingSidebar
{
    
}

- (void)showAnnotationIndicatorForAnnotation: (XCTextAnnotation *)annotation
{
    
}
- (NSArray *)annotationsForLineNumberRange:(NSRange)range
{
    
}

- (void)getParagraphRect: (CGRect *)outRect1
           firstLineRect: (CGRect *)outRect2
           forLineNumber: (NSUInteger)lineNumber
{
    
}

- (NSRange)lineNumberRangeForBoundingRect: (CGRect)rect
{
    
}
- (NSUInteger)lineNumberForPoint:(CGPoint)pos
{
    
}
- (void)breakUndoCoalescing
{
    
}
- (void)scrollRangeToVisible: (NSRange)range
                     animate: (BOOL)flag
{
    
}
- (void)insertText: (NSString *)text
  replacementRange: (NSRange)range
{
    
}

- (BOOL)allowsCodeFolding
{
    return _allowsCodeFolding;
}
- (void)setAllowsCodeFolding:(BOOL)flag
{
    if (_allowsCodeFolding != flag)
    {
        _allowsCodeFolding = flag;
    }
}

- (void)setTextStorage: (NSTextStorage *)textStorage
{
    [self setTextStorage: textStorage
           keepOldLayout: NO];
}
- (void)setTextStorage: (NSTextStorage *)textStorage
         keepOldLayout: (BOOL)flag
{
    
}

- (NSTextStorage *)textStorage
{
    return [super textStorage];
}

- (void)doCommandBySelector: (SEL)sel
{
    
}

#pragma mark - accessibility

- (CGRect)_accessibilityBoundsOfChild: (id)arg1
{
    
}
- (id)accessibilityStyleRangeForIndexAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilityAttributedStringForRangeAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilityRTFForRangeAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilityBoundsForRangeAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilityRangeForIndexAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilityStringForRangeAttributeForParameter:(id)arg1
{
    
}
- (id)accessibilitySharedTextUIElementsAttribute
{
    
}
- (void)accessibilitySetVisibleCharacterRangeAttribute:(id)arg1
{
    
}
- (id)accessibilityNumberOfCharactersAttribute
{
    
}
- (void)accessibilitySetSelectedTextRangesAttribute:(id)arg1
{
    
}
- (id)accessibilitySelectedTextRangesAttribute
{
    
}
- (void)accessibilitySetSelectedTextRangeAttribute:(id)arg1
{
    
}
- (void)accessibilitySetValueAttribute:(id)arg1
{
    
}
- (id)accessibilityValueAttribute
{
    
}
- (id)accessibilityTextLinkAtIndex:(NSUInteger)arg1
{
    
}
- (id)accessibilityTextLinks
{
    
}
- (id)accessibilityAttachmentAtIndex:(NSUInteger)arg1
{
    
}
- (NSUInteger)accessibilityIndexForAttachment:(id)arg1
{
    
}
- (id)accessibilityAttachments
{
    
}
- (NSRange)accessibilitySharedCharacterRange
{
    
}
- (id)accessibilitySharedTextViews
{
    
}
- (NSRange)accessibilityStyleRangeForCharacterIndex:(NSUInteger)arg1
{
    
}
- (id)accessibilityAXAttributedStringForCharacterRange: (NSRange)arg1
                                                parent: (id)arg2
{
    
}
- (id)accessibilityRTFForCharacterRange:(NSRange)arg1
{
}
- (CGRect)accessibilityBoundsForCharacterRange:(NSRange)arg1
{
    
}
- (NSRange)accessibilityCharacterRangeForPosition:(CGPoint)arg1
{
    
}
- (NSRange)accessibilityCharacterRangeForLineNumber:(NSUInteger)arg1
{
    
}
- (NSUInteger)accessibilityLineNumberForCharacterIndex:(NSUInteger)arg1
{
    
}
- (NSUInteger)accessibilityInsertionPointLineNumber
{
    
}
- (void)accessibilitySetVisibleCharacterRange:(NSRange)arg1
{
    
}
- (NSRange)accessibilityVisibleCharacterRange
{
    
}
- (void)accessibilitySetSelectedRange:(NSRange)arg1
{
    
}
- (NSRange)accessibilitySelectedRange
{
    
}
- (void)accessibilitySetSelectedText:(id)arg1
{
    
}
- (id)accessibilitySelectedText
{
}

- (void)setTypingAttributes: (NSDictionary *)attrs
{
    
}
- (void)viewDidEndLiveResize
{
    
}
- (void)viewWillStartLiveResize
{
    
}

- (void)_scrollRangeToVisible: (NSRange)range
                  forceCenter: (BOOL)flag
{
    
}
- (void)_centeredScrollRectToVisible: (CGRect)rect
                         forceCenter: (BOOL)flag
{
    
}

- (void)_adjustedCenteredScrollRectToVisible: (CGRect)rect
                                 forceCenter: (BOOL)flag
{
    
}
- (void)_setFrameSize: (CGSize)size
          forceScroll: (BOOL)flag
{
    
}

- (BOOL)_ensureLayoutCompleteForVisibleRectWithExtension:(BOOL)flag
{
    
}
- (void)_ensureLayoutCompleteToEndOfCharacterRange:(NSRange)range
{
    
}
- (void)_sizeDownIfPossible
{
    
}
- (void)setMarkedText: (NSString *)str
        selectedRange: (NSRange)range
{
    
}
- (BOOL)performDragOperation: (id<NSDraggingInfo>)info
{
    
}

- (void)_fixDragAndDropCharRangesForChangeInRanges: (OakRangeArray *)ranges
                                replacementStrings: (NSString *)strs
{
    
}
- (void)_userReplaceRange: (NSRange)range
               withString: (NSString *)str
{
    
}
- (void)didChangeText
{
    
}

- (BOOL)shouldChangeTextInRanges: (NSArray *)affectedRanges
              replacementStrings: (NSArray *)replacementStrings
{
    
}

- (void)showFindIndicatorForRange:(NSRange)range
{
    
}
- (void)_showFindIndicator
{
    
}

- (void)scrollRangeToVisible:(NSRange)range
{
    
}
- (BOOL)scrollRectToVisible:(CGRect)rect
{
    
}
- (void)scrollPoint:(CGPoint)pos
{
    
}

- (void)drawInsertionPointInRect: (CGRect)rect
                           color: (NSColor *)color
                        turnedOn: (BOOL)flag
{
    
}
- (void)updateInsertionPointStateAndRestartTimer:(BOOL)flag
{
    
}

- (void)setSelectedRanges: (OakRangeArray *)ranges
                 affinity: (NSUInteger)arg2
           stillSelecting: (BOOL)flag
{
    
}

- (OakRangeArray *)selectedRanges
{
}
- (void)setSelectedRange:(NSRange)range
{
}
- (NSRange)selectedRange
{
    
}

- (void)selectAll: (id)sender
{
    
}

- (void)becomeMainWindow
{
    
}
- (void)resignKeyWindow
{
    
}
- (void)becomeKeyWindow
{
    
}
- (BOOL)becomeFirstResponder
{
    
}
- (BOOL)resignFirstResponder
{
    
}
- (void)_invalidateDisplayForViewStatusChange
{
    
}
- (void)resetCursorRects
{
    
}
- (void)_invalidateAllRevealovers
{
    
}
- (void)indentSelectionIfIndentable: (id)arg1
{
    
}
- (void)indentSelection: (id)arg1
{
    
}

@end
