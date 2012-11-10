//
//  VDETextSiderBarView.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-10.
//
//

#import <Cocoa/Cocoa.h>

@class XCTextAnnotation;
@class VDETextSiderBarView;

@protocol XCTextSidebarViewBreakpointRangeDelegates <NSObject>

- (id)unknownLineRangeForSidebar: (VDETextSiderBarView *)siderBar;

- (id)knownBreakableLineRangesForSidebar: (VDETextSiderBarView *)siderBar;

- (BOOL)supportsDebugInformationForSidebar: (VDETextSiderBarView *)siderBar;

@end

@interface VDETextSiderBarView : NSRulerView
{

    XCTextAnnotation *_annotationBeingDragged;
    NSUInteger _origLineNumberOfAnnotationBeingDragged;
    BOOL _draggedAnnotationHasTraveled;
    NSTimer *_foldingHoverTimer;
    XCTextAnnotation *_hitAnnotationForContextualMenu;
    CGPoint _mouseLocationForContextualMenu;
    NSUInteger _hitLineNumberForContextualMenu;
}

+ (id)defaultContextualMenu;

@property (nonatomic, assign) id<XCTextSidebarViewBreakpointRangeDelegates> breakpointRangeDelegate;

- (id)annotationBeingDragged;

- (void)mouseUp: (id)arg1;
- (void)mouseDragged: (id)arg1;
- (void)mouseDown:(id)arg1;
- (void)scrollWheel:(id)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseMoved:(id)arg1;

- (void)_foldingHovered;

- (void)viewDidMoveToWindow;

- (id)lastMarkerControlClicked;
- (id)lastAnnotationControlClicked;

- (NSUInteger)lastLineNumberControlClicked;

- (CGPoint)lastPointControlClicked;

- (NSMenu *)menuForEvent: (NSEvent *)event;

- (id)annotationForPoint: ( CGPoint)pos;

- (NSUInteger)lineNumberForPoint:( CGPoint)pos;

- (void)redrawLineNumbersIfNeeded;

- (void)drawRect:( CGRect)rect;

- ( CGRect)foldbarRect;

- ( CGRect)sidebarRect;

- (NSCursor *)sidebarCursor;

@property (nonatomic, retain) NSColor *unknownBreakpointStripColor;

@property (nonatomic, retain) NSColor *badBreakpointStripColor;

@property (nonatomic, retain) NSColor *foldbarBackgroundColor;

@property (nonatomic, retain) NSColor *sidebarBackgroundColor;

@property (nonatomic) CGFloat foldbarWidth;

@property (nonatomic) CGFloat sidebarInvalidStripWidth;

@property (nonatomic) CGFloat sidebarWidth;

@property (nonatomic, retain) NSColor *lineNumberTextColor;

@property (nonatomic, retain) NSFont *lineNumberFont;

@property (nonatomic) BOOL drawsLineNumbers;

@property (nonatomic) BOOL showsFoldbar;

@property (nonatomic) BOOL showsSidebar;

- (void)_updateRulerThickness;
- (BOOL)displaysTooltips;
- (BOOL)acceptsFirstResponder;

- (void)setOrientation: (NSRulerOrientation)arg1;

- (void)dealloc;

- (id)initWithScrollView: (NSScrollView *)view
             orientation: (NSRulerOrientation)orientation;


@end
