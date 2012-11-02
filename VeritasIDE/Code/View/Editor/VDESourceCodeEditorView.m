//
//  VDESourceCodeEditorView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import "VDESourceCodeEditorView.h"
#import "VDESourceCodeEditorViewPrivateHandler.h"
#import "NoodleLineNumberMarker.h"
#import "NoodleLineNumberView.h"

@interface VDESourceCodeEditorView ()
{
@private
    VDESourceCodeEditorViewPrivateHandler *_handler;
}
@end

@implementation VDESourceCodeEditorView

static void VDESourceCodeEditorViewInitialize(VDESourceCodeEditorView *self)
{
    [self setFont: [NSFont fontWithName: @"Menlo"
                                   size: 11]];
    [self setAllowsUndo: YES];
    [self setUsesRuler: YES];
    
    self->_handler = [[VDESourceCodeEditorViewPrivateHandler alloc] initWithEditorView: self];
}

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        VDESourceCodeEditorViewInitialize(self);
    }
    
    return self;
}

- (id)initWithFrame: (NSRect)frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        VDESourceCodeEditorViewInitialize(self);
    }
    
    return self;
}

- (void)dealloc
{
    [_handler release];
    
    [super dealloc];
}

#pragma mark - ruler view (breakpoint)


- (BOOL)rulerView: (NSRulerView *)ruler
 shouldMoveMarker: (NSRulerMarker *)marker
{
    return YES;
}

// This is sent when a drag operation is just beginning for a ruler marker already on the ruler.  If the ruler object should be allowed to either move or remove, return YES.  If you return NO, all tracking is abandoned and nothing happens.

- (CGFloat)rulerView: (NSRulerView *)ruler
      willMoveMarker: (NSRulerMarker *)marker
          toLocation: (CGFloat)location
{
    return location;
}

// This is sent continuously while the mouse is being dragged.  The client can constrian the movement by returning a different location.  Receipt of one or more of these messages does not guarantee that the corresponding "did" method will be called.  Only movable objects will send this message.

- (void)rulerView: (NSRulerView *)ruler
    didMoveMarker: (NSRulerMarker *)marker
{
    
}

// This is called if the NSRulerMarker actually ended up with a different location than it started with after the drag completes.  It is not called if the object gets removed, or if the object gets dragged around and dropped right where it was.  Only movable objects will send this message.

- (BOOL) rulerView: (NSRulerView *)ruler
shouldRemoveMarker: (NSRulerMarker *)marker
{
    return YES;
}

// This is sent each time the object is dragged off the baseline enough that if it were dropped, it would be removed.  It can be sent multiple times in the course of a drag.  Return YES if it's OK to remove the object, NO if not.  Receipt of this message does not guarantee that the corresponding "did" method will be called.  Only removable objects will send this message.

- (void)rulerView: (NSRulerView *)ruler
  didRemoveMarker: (NSRulerMarker *)marker
{
    
}

// This is sent if the object is actually removed.  The object has been removed from the ruler when this message is sent.
//
//- (BOOL)rulerView: (NSRulerView *)ruler
//  shouldAddMarker: (NSRulerMarker *)marker
//{
//    return YES;
//}

// This is sent when a drag operation is just beginning for a ruler marker that is being added.  If the ruler object should be allowed to add, return YES.  If you return NO, all tracking is abandoned and nothing happens.

- (CGFloat)rulerView: (NSRulerView *)ruler
       willAddMarker: (NSRulerMarker *)marker
          atLocation: (CGFloat)location
{
    return location;
}

// This is sent continuously while the mouse is being dragged during an add operation and the new object is stuck on the baseline.  The client can constrian the movement by returning a different location.  Receipt of one or more of these messages does not guarantee that the corresponding "did" method will be called.  Any object sending these messages is not yet added to the ruler it is being dragged on.

- (void)rulerView: (NSRulerView *)ruler
     didAddMarker: (NSRulerMarker *)marker
{
    
}
// This is sent after the object has been added to the ruler.

- (void)rulerView: (NSRulerView *)ruler
  handleMouseDown: (NSEvent *)event
{
    NoodleLineNumberView *rulerView = (NoodleLineNumberView *)ruler;
    
    NSPoint location = [rulerView convertPoint: [event locationInWindow]
                                      fromView: nil];
    NSUInteger line = [rulerView lineNumberForLocation: location.y];
    
    if (line != NSNotFound)
    {
        NoodleLineNumberMarker *marker = [rulerView markerAtLine: line];
        
        if (marker)
        {
            [rulerView removeMarker: marker];
            
        }else
        {
            marker = [[NoodleLineNumberMarker alloc] initWithRulerView: rulerView
                                                            lineNumber: line];
            [rulerView trackMarker: marker
                    withMouseEvent: event];
            
            [marker release];
        }
        
        [self setNeedsDisplay: YES];
    }
    
}

@end
