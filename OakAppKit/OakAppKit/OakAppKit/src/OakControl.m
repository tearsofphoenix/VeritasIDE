#import "OakControl Private.h"
#import "NSView+Additions.h"
#import <OakFoundation/OakFoundation.h>

@implementation OakLayer

- (id)init
{
    if((self = [super init]))
    {
        _rect = NSZeroRect;
        _requisite = 0;
        
		_requisiteMask = 0;
		_tag = 0;
        _action = NULL;
        _color = nil;
        _text = nil;
        _image = nil;
        _view = nil;
        _textOptions = OakLayerTextNone;
        _imageOptions = OakLayerImageNoRepeat;
		_preventWindowOrdering = NO;
        
    }
    
    return self;
}

@end
// The lineBreakMode parameter is here to work around a crash in CoreText <rdar://6940427> — fixed in 10.6
static CFAttributedStringRef AttributedStringWithOptions (NSString* string,
                                                          OakLayerTextOption options,
                                                          NSLineBreakMode lineBreakMode)
{
	OakAttributedString *text = [[OakAttributedString alloc] init];
    [text appendFont: [NSFont controlContentFontOfSize:[NSFont smallSystemFontSize]]];
    [text appendLineBreakMode: lineBreakMode];
    
	if(options & OakLayerTextShadow)
	{
		NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		[shadow setShadowBlurRadius:1.0];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.8]];
		[text appendShadow: shadow];
	}
    
	[text appendString: string];
    
	return (CFAttributedStringRef)[text mutableAttributedString];
}

double WidthOfText (NSString* string)
{
	double width = 0;
    
	CTLineRef line = CTLineCreateWithAttributedString(AttributedStringWithOptions(string, 0,  NSLineBreakByTruncatingTail));
	width          = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	CFRelease(line);
    
	return ceil(width);
}

static void DrawTextWithOptions (NSString* string, NSRect bounds, OakLayerTextOption textOptions)
{
	[NSGraphicsContext saveGraphicsState];
    
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, bounds);
    
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(AttributedStringWithOptions(string, textOptions, bounds.size.width < 12 ? NSLineBreakByClipping : NSLineBreakByTruncatingTail));
	if(!framesetter)
		return;
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	CFRelease(framesetter);
	if(!frame)
		return;
    
	CTFrameDraw(frame, context);
    
	CFRelease(frame);
	CFRelease(path);
    
	[NSGraphicsContext restoreGraphicsState];
}

@interface OakControl ()

- (void)setupTrackingRects;

@end

@implementation OakControl
{
	NSInteger _tag;
    
	NSMutableArray *_layout;
	BOOL _isTransparent;
	BOOL _mouseTrackingDisabled;
    
	// ===================
	// = MouseDown State =
	// ===================
    
	BOOL _isInMouseDown;
	NSPoint _mouseDownPos;
}

@synthesize tag = _tag;
@synthesize mouseTrackingDisabled = _mouseTrackingDisabled;

- (NSArray *)layers
{
	return  [NSArray arrayWithArray: _layout];
}

- (void)setLayers: (NSArray *)aLayout
{
	// Remove views that are no longer in the layout
	for(OakLayer * oldLayer in _layout)
	{
		if([oldLayer view])
		{
			BOOL found = NO;
			for(OakLayer *newLayer in aLayout)
			{
				if([newLayer view] == [oldLayer view])
				{
					found = YES;
					break;
				}
			}
			if(!found)
            {
				[[oldLayer view] removeFromSuperview];
            }
		}
	}
    
	// TODO this triggers a redraw — may want to consider if we can delta update…
	[_layout setArray: aLayout];
    
	NSRect coveredRect = NSZeroRect;
	for(OakLayer *layer in _layout)
	{
		if([layer color] || ([layer image] && [layer requisite] == OakLayerNoRequisite))
        {
			coveredRect = NSUnionRect(coveredRect, [layer rect]);
        }

        NSView* view = [layer view];
        
		if(view)
		{
			if([view superview] != self)
            {
				[view removeFromSuperview];
            }
            
			NSRect viewFrame = [layer rect];
			if(view.frame.size.height > 0)
            {
				viewFrame.size.height = view.frame.size.height;
            }
            
			viewFrame.origin.x += [layer contentOffset].x;
			viewFrame.origin.y += [layer contentOffset].y;
            
			[view setFrame: viewFrame];
			
            [self addSubview: view];
		}
	}
    
	_isTransparent = !NSContainsRect(coveredRect, [self bounds]);
    
	[self setupTrackingRects];
}

- (BOOL)isOpaque
{
	return !_isTransparent;
}

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent
{
	return YES;
}

- (NSInteger)tagForLayerContainingPoint:(NSPoint)aPoint
{
	NSInteger res = NSNotFound;
	for(OakLayer *it in _layout)
	{
		if(NSMouseInRect(aPoint, [it rect], [self isFlipped]))
        {
			res = [it tag];
        }
	}
	return res;
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent*)event
{
	// This code is copy/paste from mouseDown: and should ideally be de-duplicated.
	OakLayer * clickLayer = NULL;
	OakLayer * dragLayer  = NULL;
	uint32_t state      = ([self currentState]
                           | OakLayerMouseClicked
                           | OakLayerMouseDragged
                           | OakLayerMouseDown
                           | OakLayerMenuGesture);
    
	NSPoint mousePos    = [self convertPoint:[event locationInWindow] fromView:nil];
    
	for(OakLayer * it in _layout)
	{
		if(![it action] || [it requisite] != (state & [it requisiteMask]) || !NSMouseInRect(mousePos, [it rect], [self isFlipped]))
        {
			continue;
        }
        
		if([it requisite] & [it requisiteMask] & (OakLayerMouseClicked
                                                  | OakLayerMouseDown
                                                  | OakLayerMenuGesture
                                                  | OakLayerMouseDoubleClicked))
		{
			clickLayer = it;
			dragLayer  = NULL; // we ignore all drag layers “behind” the click-layer, for example the close button of a tab is a click-layer, behind it is the bigger (draggable) tab, but we want to ignore that when clicking (and dragging) the close button
		}
        
		if([event clickCount] == 1 && ([it requisite] & [it requisiteMask] & OakLayerMouseDragged))
        {
			dragLayer = it;
        }
	}
    
	return dragLayer || (clickLayer && [clickLayer preventWindowOrdering]);
}

- (uint32_t)currentState
{
	NSUInteger modifierFlags = [[NSApp currentEvent] modifierFlags];
	struct
    {
        BOOL active;
        OakLayerRequisite requisite;
    } states[] =
	{
		{ [[self window] isKeyWindow],                                 OakLayerWindowKey  },
		{ [[self window] isMainWindow],                                OakLayerWindowMain },
		{ [NSApp isActive],                                            OakLayerAppActive  },
		{ (modifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask,  OakLayerOption      },
		{ (modifierFlags & NSControlKeyMask) == NSControlKeyMask,      OakLayerControl     },
		{ (modifierFlags & NSShiftKeyMask) == NSShiftKeyMask,          OakLayerShift       },
		{ (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask,      OakLayerCommand     },
	};
    
	uint32_t res = 0;
	for(NSUInteger i = 0; i < sizeof(states) / sizeof(states[0]); ++i)
	{
		if(states[i].active)
        {
			res |= states[i].requisite;
        }
	}
    
	if(res & OakLayerWindowMain || res & OakLayerWindowKey)
    {
		res |= OakLayerWindowMainOrKey;
    }
    
	return res;
}

- (void)drawLayer:(OakLayer *)aLayer
{
	if(aLayer.color)
	{
		[[aLayer color] set];
        
		NSRectFill(aLayer.rect);
	}
    
	if(aLayer.image)
	{
		if([aLayer imageOptions] & OakLayerImageStretch)
		{
			[[aLayer image] drawInRect: [aLayer rect]
                              fromRect: NSZeroRect
                             operation: NSCompositeCopy
                              fraction: 1.0];
		}
		else
		{
			NSPoint origin = NSMakePoint([aLayer rect].origin.x + [aLayer contentOffset].x, [aLayer rect].origin.y + [aLayer contentOffset].y);
            
			[[aLayer image] drawAtPoint: origin
                               fromRect: NSZeroRect
                              operation: NSCompositeSourceOver
                               fraction: 1.0];
		}
	}
    
	if([aLayer text])
    {
		DrawTextWithOptions([aLayer text], [aLayer rect], [aLayer textOptions]);
    }
}

- (void)drawRect:(NSRect)aRect
{
	NSPoint mousePos = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
	uint32_t state   = [self currentState];
    
	for(OakLayer *it in _layout)
	{
		if(NSEqualRects(NSIntersectionRect(aRect, [it rect]), NSZeroRect))
			continue;
        
		// if we are in a mouseDown: then use the location from that first press for all but the clicked layer (so moving mouse while holding left mouse button doesn’t update layer states)
		uint32_t mouseState = 0;
        
		if(!_mouseTrackingDisabled)
		{
			BOOL isInLayer    = NSMouseInRect(mousePos, [it rect], [self isFlipped]);
			BOOL clickedLayer = NSMouseInRect(_mouseDownPos, [it rect], [self isFlipped]);
            
			if(isInLayer)
            {
				mouseState |= OakLayerMouseInside;
            }
            
			if(_isInMouseDown && clickedLayer)
				mouseState |= (OakLayerMouseClicked
                               | OakLayerMenuGesture);
		}
        
		if(((state | mouseState) & [it requisiteMask]) == [it requisite])
        {
			[self drawLayer: it];
        }
	}
}

- (void)sendAction: (SEL)action
         fromLayer: (OakLayer *)aLayer
{
	_tag = [aLayer tag];
    
	NSResponder* candidate = self;
	while(candidate)
	{
		if([candidate respondsToSelector:action])
			return (void)[candidate performSelector:action withObject:self];
		else if([candidate respondsToSelector:@selector(delegate)] && [[candidate performSelector:@selector(delegate)] respondsToSelector:action])
			return (void)[[candidate performSelector:@selector(delegate)] performSelector:action withObject:self];
		candidate = [candidate nextResponder];
	}
}

- (void)mouseDown:(NSEvent*)event
{    
	OakLayer * clickLayer = NULL;
	OakLayer * dragLayer  = NULL;
	uint32_t state      =  ([self currentState]
                            | OakLayerMouseClicked
                            | OakLayerMouseDragged
                            | OakLayerMouseDown
                            | OakLayerMenuGesture);
    
	_mouseDownPos        = [self convertPoint:[event locationInWindow] fromView:nil];
    
	if([event clickCount] == 2)
    {
		state |= OakLayerMouseDoubleClicked;
    }
    
	for(OakLayer *it in _layout)
	{
		if(![it action] || [it requisite] != (state & [it requisiteMask]) || !NSMouseInRect(_mouseDownPos, [it rect], [self isFlipped]))
        {
			continue;
        }
        
		if([it requisite] & [it requisiteMask] & (OakLayerMouseClicked
                                                  | OakLayerMouseDown
                                                  | OakLayerMenuGesture
                                                  | OakLayerMouseDoubleClicked))
		{
			clickLayer = it;
			dragLayer  = NULL; // we ignore all drag layers “behind” the click-layer, for example the close button of a tab is a click-layer, behind it is the bigger (draggable) tab, but we want to ignore that when clicking (and dragging) the close button
		}
        
		if([event clickCount] == 1 && ([it requisite] & [it requisiteMask] & OakLayerMouseDragged))
        {
			dragLayer = it;
        }
	}
    
	if(!clickLayer && !dragLayer)
		return;
    
	if(clickLayer && [clickLayer preventWindowOrdering])
    {
		[(NSApplication *)NSApp preventWindowOrdering];
    }
    
	if(clickLayer && ([clickLayer requisite] & [clickLayer requisiteMask] & (OakLayerMouseDown
                                                                             | OakLayerMouseDoubleClicked)))
    {
		return [self sendAction: [clickLayer action]
                      fromLayer: clickLayer];
    }
    
	_isInMouseDown = YES;
    
	if(clickLayer)
    {
		[self setNeedsDisplayInRect: [clickLayer rect]];
    }
    
	BOOL isInside = YES;
	NSDate* untilDate = ([clickLayer requisite] & [clickLayer requisiteMask] & OakLayerMenuGesture) ? [NSDate dateWithTimeIntervalSinceNow: 1] : [NSDate distantFuture];
	while(true)
	{
		NSPoint mousePos = [self convertPoint: [event locationInWindow]
                                     fromView: nil];
        
		if(([clickLayer requisite] & [clickLayer requisiteMask] & OakLayerMenuGesture)
           && (event == nil || event.type == NSRightMouseDown || (event.type == NSLeftMouseDown && ([event modifierFlags] & NSControlKeyMask) == NSControlKeyMask)))
		{
			[self sendAction: [clickLayer menuAction]
                   fromLayer: clickLayer];
			break;
            
		}else if([event type] == NSLeftMouseUp && clickLayer)
		{
			if(NSMouseInRect(mousePos, [clickLayer rect], [self isFlipped]))
				[self sendAction: [clickLayer action]
                       fromLayer: clickLayer];
		}
		else if([event type] == NSLeftMouseDragged)
		{
			if(dragLayer)
			{
				if(2.5 <= sqrt(OakSquare(_mouseDownPos.x - mousePos.x) + OakSquare(_mouseDownPos.y - mousePos.y)))
				{
					_tag = [dragLayer tag];
					[NSApp sendAction: [dragLayer action]
                                   to: self
                                 from: self];
					break;
				}
			}
			else if(clickLayer && isInside != NSMouseInRect(mousePos, [clickLayer rect], [self isFlipped]))
			{
				[self setNeedsDisplayInRect: [clickLayer rect]];
				isInside = !isInside;
			}
		}
        
		if(event.type == NSLeftMouseUp)
			break;
        
		event = [NSApp nextEventMatchingMask: (NSLeftMouseUpMask
                                               | NSLeftMouseDraggedMask
                                               | NSRightMouseDownMask)
                                   untilDate: untilDate
                                      inMode: NSEventTrackingRunLoopMode
                                     dequeue: YES];
	}
    
	_isInMouseDown = NO;
	if(clickLayer)
    {
		[self setNeedsDisplayInRect: [clickLayer rect]];
    }
	// ideally we should call [self setNeedsDisplayInRect:clickLayer->rect] but redraw seems to happen anyway (probably due to mouseExited:) — calling it explicitly can cause small render quirks, i.e. redrawing first the close button (in a tab) as “not inside” and then on second redraw, the entire tab (causing the transparent areas of teh close button to momentarily look wrong)
}

// ============
// = Tracking =
// ============

- (void)clearTrackingRects
{
	for(NSTrackingArea* trackingArea in self.trackingAreas)
		[self removeTrackingArea:trackingArea];
	[self removeAllToolTips];
}

- (void)setupTrackingRects
{
	[self clearTrackingRects];
	if(self.mouseTrackingDisabled)
		return;
    
	NSMutableDictionary *trackedLayers = [NSMutableDictionary dictionary];
    
	for(OakLayer *it in _layout)
	{
		if([it requisite] & OakLayerMouseInside || [it requisiteMask] & OakLayerMouseInside)
        {
            NSValue *rectValue = [NSValue valueWithRect: [it rect]];
            
            NSMutableArray *array = [trackedLayers objectForKey: rectValue];
            if (!array)
            {
                array = [[NSMutableArray alloc] init];
                [trackedLayers setObject: array
                                  forKey: rectValue];
                [array release];
            }
            
            [array addObject: it];
        }
        
		if([it toolTip])
        {
			[self addToolTipRect: [it rect]
                           owner: [it toolTip]
                        userData: NULL];
        }
	}
    
	[trackedLayers enumerateKeysAndObjectsUsingBlock: (^(NSValue *rectKey, NSArray *obj, BOOL *stop)
                                                       {
                                                           NSTrackingAreaOptions trackingOptions = NSTrackingMouseEnteredAndExited;
                                                           
                                                           for(OakLayer *layer in obj)
                                                           {
                                                               if(!([layer requisite] & OakLayerWindowKey))
                                                               {
                                                                   trackingOptions |= NSTrackingActiveAlways;
                                                                   break;
                                                               }
                                                           }
                                                           
                                                           if(!(trackingOptions & NSTrackingActiveAlways))
                                                           {
                                                               trackingOptions |= NSTrackingActiveInKeyWindow;
                                                           }
                                                           
                                                           NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect: [rectKey rectValue]
                                                                                                                       options: trackingOptions
                                                                                                                         owner: self
                                                                                                                      userInfo: nil];
                                                           [self addTrackingArea: trackingArea];
                                                           [trackingArea release];
                                                       })];
}

- (void)setMouseTrackingDisabled:(BOOL)flag
{
	_mouseTrackingDisabled = flag;
    
	[self setupTrackingRects];
}

- (void)mouseEntered:(NSEvent*)event
{
	if(!self.mouseTrackingDisabled)
		[self setNeedsDisplayInRect:[[event trackingArea] rect]];
}

- (void)mouseExited:(NSEvent*)event
{
	if(!self.mouseTrackingDisabled)
		[self setNeedsDisplayInRect:[[event trackingArea] rect]];
}

- (void)viewWillMoveToWindow:(NSWindow*)newWindow
{
	[self clearTrackingRects];
	if(newWindow)
		[self setupTrackingRects];
}

- (void)setKeyState:(NSUInteger)newState
{
	[super setKeyState:newState];
	// TODO only redraw the layers which has requisite set so that they would change on view/window/app focus changes
	[self setNeedsDisplay:YES];
}
@end
