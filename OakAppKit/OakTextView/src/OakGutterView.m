#import "OakGutterView.h"
#import <OakAppKit/OakAppKit.h>
#import <OakFoundation/OakFoundation.h>

NSString* GVColumnDataSourceDidChange   = @"GVColumnDataSourceDidChange";
NSString* GVLineNumbersColumnIdentifier = @"lineNumbers";

static CGFloat WidthOfLineNumbers (NSUInteger lineNumber, NSFont* font);

@interface  OakGutterViewDataSource : NSObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) id datasource;
@property (nonatomic, retain) id delegate;
@property (nonatomic) CGFloat x0;
@property (nonatomic)  CGFloat width;

@end

@implementation OakGutterViewDataSource


@end

static id OakGutterViewDataSourceMake()
{
    return nil;
}

@interface OakGutterView ()

- (CGFloat)widthForColumnWithIdentifier:(NSString *)identifier;

- (OakGutterViewDataSource *)columnWithIdentifier:(NSString *)identifier;

- (void)clearTrackingRects;

- (void)setupTrackingRects;

@end

@implementation OakGutterView
{
	NSMutableArray *_columnDataSources;
	NSMutableSet* hiddenColumns;
	NSString * highlightedRange;
	OakMutableRectArray *backgroundRects;
    OakMutableRectArray *borderRects;

	NSPoint mouseDownAtPoint;
	NSPoint mouseHoveringAtPoint;
}

// ==================
// = Setup/Teardown =
// ==================

- (id)initWithFrame:(NSRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		hiddenColumns       = [NSMutableSet new];
		self.lineNumberFont = [NSFont userFixedPitchFontOfSize:12];
		[self insertColumnWithIdentifier:GVLineNumbersColumnIdentifier atPosition:0 dataSource:nil delegate:nil];

		mouseDownAtPoint     = NSMakePoint(-1, -1);
		mouseHoveringAtPoint = NSMakePoint(-1, -1);

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cursorDidHide:) name:OakCursorDidHideNotification object:nil];
	}
	return self;
}

- (void)updateTrackingAreas
{
	
	[super updateTrackingAreas];
	[self setupTrackingRects];
}

- (void)removeFromSuperview
{
	
	self.partnerView = nil;
}

- (void)viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSWindowDidResignKeyNotification
                                                  object: nil];
	if(self.window)
    {
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(windowDidResignKey:)
                                                     name: NSWindowDidResignKeyNotification
                                                   object: self.window];
    }
}

- (void)windowDidResignKey:(NSNotification*)notification
{
	[self mouseExited:nil];
}

- (void)dealloc
{
	
	self.partnerView               = nil;
	self.lineNumberFont            = nil;
	self.foregroundColor           = nil;
	self.backgroundColor           = nil;
	self.iconColor                 = nil;
	self.iconHoverColor            = nil;
	self.iconPressedColor          = nil;
	self.selectionForegroundColor  = nil;
	self.selectionBackgroundColor  = nil;
	self.selectionIconColor        = nil;
	self.selectionIconHoverColor   = nil;
	self.selectionIconPressedColor = nil;
	self.selectionBorderColor      = nil;
	for(id it in _columnDataSources)
	{
		if([it datasource])
        {
			[[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: GVColumnDataSourceDidChange
                                                          object: [it datasource]];
        }
	}
    
	[hiddenColumns release];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

- (void)setupSelectionRects
{
	[backgroundRects removeAllObjects];
	[borderRects removeAllObjects];

//	citerate(range, text::selection_t(highlightedRange))
//	{
//		auto from = range->min(), to = range->max();
//		CGFloat firstY = [self.delegate lineFragmentForLine:from.line column:from.column].firstY;
//		auto fragment = [self.delegate lineFragmentForLine:to.line column:to.column];
//		CGFloat lastY = to.column == 0 && from.line != to.line ? fragment.firstY : fragment.lastY;
//
//		backgroundRects.push_back(CGRectMake(0, firstY+1, self.frame.size.width, lastY - firstY - 2));
//		borderRects.push_back(CGRectMake(0, firstY, self.frame.size.width, 1));
//		borderRects.push_back(CGRectMake(0, lastY-1, self.frame.size.width, 1));
//	}
}

// =============
// = Accessors =
// =============

- (void)setHighlightedRange:(NSString *)str
{
	NSMutableArray *oldBackgroundRects = [NSMutableArray arrayWithArray: backgroundRects];
    NSMutableArray *oldBorderRects = [NSMutableArray arrayWithArray: borderRects];
    NSMutableArray *refreshRects = [NSMutableArray array];

    
	highlightedRange = str;

	[self setupSelectionRects];

    [refreshRects addObjectsFromArray: [oldBackgroundRects differenceArrayWithArray: backgroundRects]];
    [refreshRects addObjectsFromArray: [oldBorderRects differenceArrayWithArray: borderRects]];

	for(NSValue *rect in refreshRects)
    {
		[self setNeedsDisplayInRect: [rect rectValue]];
    }
}

- (void)setPartnerView:(NSView*)aView
{

	if(_partnerView)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[_partnerView release];
	}

	if((_partnerView = [aView retain]))
    {
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(boundsDidChange:)
                                                     name: NSViewBoundsDidChangeNotification
                                                   object: [[_partnerView enclosingScrollView] contentView]];
    }
}

- (void)insertColumnWithIdentifier: (NSString*)columnIdentifier
                        atPosition: (NSUInteger)index
                        dataSource: (id <GutterViewColumnDataSource>)columnDataSource
                          delegate: (id <GutterViewColumnDelegate>)columnDelegate
{
    OakGutterViewDataSource *ds = [[OakGutterViewDataSource alloc] init];
    [ds setIdentifier: columnIdentifier];
    [ds setDatasource: columnDataSource];
    [ds setDelegate: columnDelegate];
    
	[_columnDataSources insertObject: ds
                             atIndex: index];
    [ds release];
    
     if(columnDelegate)
    {
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(columnDataSourceDidChange:)
                                                     name: GVColumnDataSourceDidChange
                                                   object: columnDelegate];
    }
    
	[self reloadData: self];
}

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)visibilityForColumnWithIdentifier:(NSString*)identifier
{
	return ![hiddenColumns containsObject:identifier];
}

- (CGFloat)widthForColumnWithIdentifier:(NSString *)identifier
{
	CGFloat width = 0;
	if(![self delegate])
    {
		return 5;
    }
	if([identifier isEqualToString: GVLineNumbersColumnIdentifier])
	{
		NSUInteger lastLineNumber = [self.delegate lineRecordForPosition: NSHeight([_partnerView frame])].lineNumber;
        
		CGFloat newWidth = WidthOfLineNumbers(lastLineNumber == NSNotFound ? 0 : lastLineNumber + 1, self.lineNumberFont);

		width = [[self columnWithIdentifier: identifier] width];
        
		if(width < newWidth || (newWidth < width && WidthOfLineNumbers(lastLineNumber * 4/3, self.lineNumberFont) < width))
        {
			width = newWidth;
        }
	}
	else
	{
		NSUInteger n = 1;
        NSImage *img = nil;
		while((img = [[[self columnWithIdentifier: identifier] datasource] imageForState: n++
                                                                 forColumnWithIdentifier: identifier]))
        {
			width = MAX(width, [img size].width);
        }
	}

	return ceil(width);
}

- (OakGutterViewDataSource*)columnWithIdentifier:(NSString *)identifier
{
	for(OakGutterViewDataSource *it in _columnDataSources)
	{
		if([[it identifier] isEqualToString: identifier])
        {
			return it;
        }
	}
    
	assert(false);
	
    return nil;
}

- (NSArray *)visibleColumnDataSources
{
	NSMutableArray *visibleColumnDataSources = [NSMutableArray array];

	for(OakGutterViewDataSource *it in _columnDataSources)
	{
		if([self visibilityForColumnWithIdentifier:  [it identifier]])
        {
			[visibleColumnDataSources addObject: it];
        }
	}
    
	return visibleColumnDataSources;
}

// ================
// = Data sources =
// ================

- (NSImage*)imageForColumn: (NSString *)identifier
                    atLine: (NSUInteger)lineNumber
                  hovering: (BOOL)hovering
                   pressed: (BOOL)pressed
{
	id datasource    = [[self columnWithIdentifier: identifier] datasource];
	NSUInteger state = [datasource stateForColumnWithIdentifier: identifier
                                                         atLine: lineNumber];
	NSImage* image   = nil;

	if(pressed && [datasource respondsToSelector: @selector(pressedImageForState:forColumnWithIdentifier:)])
    {
		image = [datasource pressedImageForState: state
                         forColumnWithIdentifier: identifier];
        
    }else if(hovering && [datasource respondsToSelector: @selector(hoverImageForState:forColumnWithIdentifier:)])
    {
		image = [datasource hoverImageForState: state
                       forColumnWithIdentifier: identifier];
    }
    
	return image ?: [datasource imageForState: state
                      forColumnWithIdentifier: identifier];
}

// ==========
// = Events =
// ==========

- (void)boundsDidChange:(NSNotification*)aNotification
{
	[self.enclosingScrollView.contentView scrollToPoint:NSMakePoint(0, NSMinY(_partnerView.enclosingScrollView.contentView.bounds))];
	if([self updateWidth] != NSWidth(self.frame))
		[self invalidateIntrinsicContentSize];
}

static CTLineRef CTCreateLineFromText (NSString * text, NSFont* font, NSColor* color)
{
    OakAttributedString *attrString = [[OakAttributedString alloc] init];
    [attrString appendString: text];
    [attrString appendFont: font];
    [attrString appendBackgroundColor: (color ?: [NSColor grayColor])];
    
	return CTLineCreateWithAttributedString((CFAttributedStringRef)[attrString mutableAttributedString]);
}

static CGFloat WidthOfLineNumbers (NSUInteger lineNumber, NSFont* font)
{
	CTLineRef line = CTCreateLineFromText([NSString stringWithFormat: @"%ld", MAX(10, lineNumber)], font, nil);
	CGFloat width  = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	CFRelease(line);
	return ceil(width);
}

static void DrawText (NSString * text, CGRect  rect, CGFloat baseline, NSFont* font, NSColor* color)
{
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context);

	CTLineRef line = CTCreateLineFromText(text, font, color);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, 2 * baseline));
	CGContextSetTextPosition(context, CGRectGetMaxX(rect) - CTLineGetTypographicBounds(line, NULL, NULL, NULL), baseline);
	CTLineDraw(line, context);
	CFRelease(line);

	CGContextRestoreGState(context);
}

- (void)drawRect:(NSRect)aRect
{
	[self.backgroundColor set];
	NSRectFill(NSIntersectionRect(aRect, self.frame));

	[self setupSelectionRects];

	[self.selectionBackgroundColor set];
	for(NSValue *rect in backgroundRects)
    {
		NSRectFillUsingOperation(NSIntersectionRect([rect rectValue], NSIntersectionRect(aRect, self.frame)), NSCompositeSourceOver);
    }

	[self.selectionBorderColor set];
	for(NSValue *rect in borderRects)
    {
		NSRectFillUsingOperation(NSIntersectionRect([rect rectValue], NSIntersectionRect(aRect, self.frame)), NSCompositeSourceOver);
    }

	NSRange prevLine = NSMakeRange(NSNotFound, 0);
    
	for(CGFloat y = NSMinY(aRect); y < NSMaxY(aRect); )
	{
		GVLineRecord record = [self.delegate lineRecordForPosition:y];
		if(record.lastY <= y || (prevLine.location == record.lineNumber
                                 && prevLine.length == record.softlineOffset) )
			break;
		prevLine = NSMakeRange(record.lineNumber, record.softlineOffset);

		BOOL selectedRow = NO;
		for(NSValue *rect in backgroundRects)
        {
			selectedRow = selectedRow || NSIntersectsRect([rect rectValue], NSMakeRect(0, record.firstY, CGRectGetWidth(self.frame), record.lastY - record.firstY));
        }
        
		for(id dataSource in [self visibleColumnDataSources])
		{
			NSRect columnRect = NSMakeRect([dataSource x0], record.firstY, [dataSource width], record.lastY - record.firstY);
			if([[dataSource identifier] isEqualToString: GVLineNumbersColumnIdentifier])
			{
				NSColor* textColor = selectedRow ? self.selectionForegroundColor : self.foregroundColor;
				DrawText(record.softlineOffset == 0 ? [NSString stringWithFormat: @"%ld", record.lineNumber + 1] : @"·",
                         columnRect, NSMinY(columnRect) + record.baseline, self.lineNumberFont, textColor);
			}
			else if(record.softlineOffset == 0)
			{
				BOOL isHoveringRect = NSMouseInRect(mouseHoveringAtPoint, columnRect, [self isFlipped]);
				BOOL isDownInRect   = NSMouseInRect(mouseDownAtPoint,     columnRect, [self isFlipped]);

				if(selectedRow && isDownInRect)        [self.selectionIconPressedColor set];
				else if(selectedRow && isHoveringRect) [self.selectionIconHoverColor   set];
				else if(selectedRow)                   [self.selectionIconColor        set];
				else if(isDownInRect)                  [self.iconPressedColor          set];
				else if(isHoveringRect)                [self.iconHoverColor            set];
				else                                   [self.iconColor                 set];

				NSImage* image = [self imageForColumn: [dataSource identifier]
                                               atLine: record.lineNumber
                                             hovering: isHoveringRect && NSEqualPoints(mouseDownAtPoint, NSMakePoint(-1, -1))
                                              pressed: isHoveringRect && isDownInRect];
                
				if([image size].height > 0 && [image size].width > 0)
				{
					// The placement of the center of image is aligned with the center of the capHeight.
					CGFloat center = record.baseline - ([self.lineNumberFont capHeight] / 2);
					CGFloat x = round((NSWidth(columnRect) - [image size].width) / 2);
					CGFloat y = round(center - ([image size].height / 2));
					NSRect imageRect = NSMakeRect(NSMinX(columnRect) + x, NSMinY(columnRect) + y, [image size].width, [image size].height);

					[NSGraphicsContext saveGraphicsState];

					NSAffineTransform* transform = [NSAffineTransform transform];
					[transform translateXBy:0 yBy:NSMaxY(imageRect)];
					[transform scaleXBy:1 yBy:-1];
					[transform concat];
					imageRect.origin.y = 0;

					CGImageRef cgImage = [image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
					CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), CGImageGetBitsPerComponent(cgImage), CGImageGetBitsPerPixel(cgImage), CGImageGetBytesPerRow(cgImage), CGImageGetDataProvider(cgImage), NULL, false);
					CGContextClipToMask((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], imageRect, imageMask);
					CFRelease(imageMask);

					NSRectFillUsingOperation(imageRect, NSCompositeSourceOver);
					[NSGraphicsContext restoreGraphicsState];
				}
			}
		}

		y = record.lastY;
	}
}

- (CGFloat)updateWidth
{
	static const CGFloat columnPadding = 1;

	CGFloat currentX = 0, totalWidth = 0;
	for(OakGutterViewDataSource *it in _columnDataSources)
	{
		[it setX0: currentX];
        
		if([self visibilityForColumnWithIdentifier: [it identifier]])
		{
            CGFloat width = [self widthForColumnWithIdentifier: [it identifier]];
			[it setWidth: width];
			totalWidth += width + columnPadding;
			currentX   += width + columnPadding;
		}
		else
		{
			[it setWidth: 0];
		}
	}

	return totalWidth;
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize([self updateWidth], NSViewNoInstrinsicMetric);
}

- (void)reloadData:(id)sender
{
	
	[self setNeedsDisplay:YES];
	if([self updateWidth] != NSWidth(self.frame))
		[self invalidateIntrinsicContentSize];
}

- (NSRect)columnRectForPoint:(NSPoint)aPoint
{
	GVLineRecord record = [self.delegate lineRecordForPosition:aPoint.y];
	if(record.lineNumber != NSNotFound && record.softlineOffset == 0)
	{
		for(OakGutterViewDataSource *dataSource in [self visibleColumnDataSources])
		{
			if([[dataSource identifier] isEqualToString: GVLineNumbersColumnIdentifier])
				continue;

			NSRect columnRect = NSMakeRect([dataSource x0], record.firstY, [dataSource width], record.lastY - record.firstY);
            
			if(NSPointInRect(aPoint, columnRect))
            {
				return columnRect;
            }
		}
	}
    
	return NSZeroRect;
}

- (void)mouseDown:(NSEvent*)event
{
	
	NSPoint pos = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect columnRect = [self columnRectForPoint:pos];
	if(NSMouseInRect(pos, columnRect, [self isFlipped]))
	{
		mouseDownAtPoint = pos;
		[self setNeedsDisplayInRect:columnRect];

		while([event type] != NSLeftMouseUp)
		{
			event = [NSApp nextEventMatchingMask: (NSLeftMouseUpMask
                                                  | NSMouseMovedMask
                                                  | NSLeftMouseDraggedMask
                                                  | NSMouseEnteredMask
                                                  | NSMouseExitedMask)
                                       untilDate: [NSDate distantFuture]
                                          inMode: NSEventTrackingRunLoopMode
                                         dequeue: YES];
            
			if([event type] == NSMouseMoved || [event type] == NSLeftMouseDragged)
            {
				[self mouseMoved:event];
            }
		}

		if(NSEqualRects(columnRect, [self columnRectForPoint:mouseHoveringAtPoint]))
		{
			GVLineRecord record = [self.delegate lineRecordForPosition:mouseDownAtPoint.y];
			for(OakGutterViewDataSource *dataSource in [self visibleColumnDataSources])
			{
				NSRect columnRect = NSMakeRect([dataSource x0], record.firstY, [dataSource width], record.lastY - record.firstY);
                
				if(NSPointInRect(mouseDownAtPoint, columnRect))
                {
					[[dataSource delegate] userDidClickColumnWithIdentifier: [dataSource identifier]
                                                                    atLine: record.lineNumber];
                }
			}
            
		}else
		{
			mouseHoveringAtPoint = NSMakePoint(-1, -1);
		}

		mouseDownAtPoint = NSMakePoint(-1, -1);
		[self setNeedsDisplayInRect:columnRect];
	}
	else
	{
		[_partnerView mouseDown:event];
        
		while([event type] != NSLeftMouseUp)
		{
			event = [NSApp nextEventMatchingMask: (NSLeftMouseUpMask
                                                   | NSMouseMovedMask
                                                   | NSLeftMouseDraggedMask
                                                   | NSMouseEnteredMask
                                                   | NSMouseExitedMask)
                                       untilDate: [NSDate distantFuture]
                                          inMode: NSEventTrackingRunLoopMode
                                         dequeue: YES];
			if([event type] == NSMouseMoved || [event type] == NSLeftMouseDragged)
            {
				[_partnerView mouseDragged:event];
            }
		}
        
		[_partnerView mouseUp:event];
	}
}

- (void)columnDataSourceDidChange:(NSNotification*)notification
{
	[self reloadData:[notification object]];
}

- (void)setVisibility:(BOOL)visible forColumnWithIdentifier:(NSString*)columnIdentifier
{
	if(visible)
			[hiddenColumns removeObject:columnIdentifier];
	else	[hiddenColumns addObject:columnIdentifier];
	[self invalidateIntrinsicContentSize];
}

// ==================
// = Tracking rects =
// ==================

- (void)clearTrackingRects
{
	for(NSTrackingArea* trackingArea in self.trackingAreas)
    {
		[self removeTrackingArea:trackingArea];
    }
}

- (void)setupTrackingRects
{
	
	[self clearTrackingRects];

	NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect: [self visibleRect]
                                                                options: (NSTrackingMouseEnteredAndExited
                                                                          | NSTrackingMouseMoved
                                                                          | NSTrackingActiveInKeyWindow)
                                                                  owner: self
                                                               userInfo: nil];
	[self addTrackingArea:trackingArea];
	[trackingArea release];
}

- (void)scrollWheel:(NSEvent*)event
{
	[_partnerView scrollWheel:event];
	[self mouseMoved:event];
}

- (void)mouseMoved:(NSEvent*)event
{
	NSRect beforeRect = [self columnRectForPoint:mouseHoveringAtPoint];
	mouseHoveringAtPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect afterRect = [self columnRectForPoint:mouseHoveringAtPoint];

	if(!NSEqualRects(beforeRect, afterRect))
	{
		[self setNeedsDisplayInRect:beforeRect];
		[self setNeedsDisplayInRect:afterRect];
	}
}

- (void)mouseExited:(NSEvent*)event
{
	NSRect columnRect = [self columnRectForPoint:mouseHoveringAtPoint];
	mouseHoveringAtPoint = NSMakePoint(-1, -1);
	[self setNeedsDisplayInRect:columnRect];
}

- (void)cursorDidHide:(NSNotification*)aNotification
{
	[self mouseExited:[[self window] currentEvent]];
}
@end
