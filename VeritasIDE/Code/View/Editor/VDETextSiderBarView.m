//
//  VDETextSiderBarView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-10.
//
//

#import "VDETextSiderBarView.h"

@implementation VDETextSiderBarView

static NSMenu *s_VDETextSiderBarContextMenu = nil;

static NSDictionary *f_VDETextAttributes(VDETextSiderBarView *self)
{
    return (@{
            NSFontAttributeName : [self lineNumberFont],
            NSForegroundColorAttributeName : [self lineNumberTextColor]
            });
}

+ (NSMenu *)defaultContextualMenu
{
    if (!s_VDETextSiderBarContextMenu)
    {
        s_VDETextSiderBarContextMenu = [[NSMenu alloc] initWithTitle: @"SiderBar"];
    }
    
    return s_VDETextSiderBarContextMenu;
}

@synthesize breakpointRangeDelegate = _breakpointRangeDelegate;

- (id)annotationBeingDragged
{
    return nil;
}

- (void)mouseUp: (NSEvent *)event
{
    
}

- (void)mouseDragged: (NSEvent *)arg1
{
    
}

- (void)mouseDown: (NSEvent *)theEvent
{
    CGPoint pos = [theEvent locationInWindow];
    
}

- (void)scrollWheel: (NSEvent *)arg1
{
    
}

- (void)mouseExited: (NSEvent *)arg1
{
    
}

- (void)mouseMoved: (NSEvent *)arg1
{
    
}

- (void)_foldingHovered
{
    
}

- (void)viewDidMoveToWindow
{
    
}

- (id)lastMarkerControlClicked
{
    
}

- (id)lastAnnotationControlClicked
{
    
}

- (NSUInteger)lastLineNumberControlClicked
{
    
}

- (CGPoint)lastPointControlClicked
{
    
}

- (NSMenu *)menuForEvent: (NSEvent *)event
{
    
}

- (id)annotationForPoint: ( CGPoint)pos
{
    
}

- (NSUInteger)lineNumberForPoint:( CGPoint)pos
{
    
}

- (void)redrawLineNumbersIfNeeded
{
    
}

- (void)drawRect:( CGRect)rect
{
    [@"1" drawAtPoint: NSMakePoint(0, 0)
       withAttributes: f_VDETextAttributes(self)];
}

- ( CGRect)foldbarRect
{
    
}

- ( CGRect)sidebarRect
{
    
}

- (NSCursor *)sidebarCursor
{
    
}

#pragma mark - ui configurations
//@synthesize  unknownBreakpointStripColor;
//
//@property (nonatomic, retain) NSColor *badBreakpointStripColor;
//
//@property (nonatomic, retain) NSColor *foldbarBackgroundColor;
//
//@property (nonatomic, retain) NSColor *sidebarBackgroundColor;
//
//@property (nonatomic) CGFloat foldbarWidth;
//
//@property (nonatomic) CGFloat sidebarInvalidStripWidth;
//
//@property (nonatomic) CGFloat sidebarWidth;
//
//@property (nonatomic, retain) NSColor *lineNumberTextColor;
//
//@property (nonatomic, retain) NSFont *lineNumberFont;
//
//@property (nonatomic) BOOL drawsLineNumbers;
//
//@property (nonatomic) BOOL showsFoldbar;
//
//@property (nonatomic) BOOL showsSidebar;

- (void)_updateRulerThickness
{
    
}

- (BOOL)displaysTooltips
{
    return NO;
}

- (BOOL)acceptsFirstResponder
{
    return NO;
}

- (void)setOrientation: (NSRulerOrientation)arg1
{
    [super setOrientation: NSVerticalRuler];
}

- (void)dealloc
{
    
    [super dealloc];
}

static void f_VDELoadDefaultSiderBarConfiguration(VDETextSiderBarView *self)
{
    [self setLineNumberFont: [NSFont fontWithName: @"Menlo"
                                             size: 9]];
    [self setLineNumberTextColor: [NSColor colorWithCalibratedRed: 0.57
                                                            green: 0.57
                                                             blue: 0.62
                                                            alpha:1.00]];
}

- (id)initWithScrollView: (NSScrollView *)view
             orientation: (NSRulerOrientation)arg2
{
    if ((self = [super initWithScrollView: view
                              orientation: NSVerticalRuler]))
    {
        f_VDELoadDefaultSiderBarConfiguration(self);
    }
    
    return self;
}

@end
