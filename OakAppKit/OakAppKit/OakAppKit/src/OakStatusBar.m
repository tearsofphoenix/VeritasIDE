#import "OakStatusBar.h"
#import "OakControl Private.h"
#import "NSColor+Additions.h"
#import "NSImage+Additions.h"
#import "NSView+Additions.h"
#import <OakFoundation/NSString+Additions.h>



@implementation OakStatusBarCell

- (id)initWithType: (OakStatusBarType)type
{
    if ((self = [super init]))
    {
        _type = type;
        _tag = 0;
        _minSize = 0;
        _maxSize = 0;
        _skipTrailingSeparator = NO;
        _state = NSOnState;
        _padding = 0;
    }
    
    return self;
}

- (void)setSizeMin: (CGFloat)minSize
               max: (CGFloat) maxSize
{
    _minSize = minSize;
    _maxSize = maxSize ?: minSize;
}

- (void)noPadding
{
    _padding = -1;
}

- (void)noSeparator
{
    _skipTrailingSeparator = YES;
}

- (void)setImage: (NSImage *)image
{
    if(_image != image)
    {
        [_image release];
        _image = [image retain];
        
        if(_type == OakStatusBarButton)
        {
            [self noPadding];
        }
    }
}

+ (id)cellWithType: (OakStatusBarType)type
            target: (id)target
            action: (SEL)action
{
    OakStatusBarCell *cell = [[OakStatusBarCell alloc] initWithType: type];
    [cell setTarget: target];
    [cell setAction: action];
    
    return [cell autorelease];
}

@end


//void cell_t::set_content (template_image  tpl)
//{
//    NSImage* templateImage = [NSImage imageNamed:tpl.name];
//    assert(templateImage);
//    NSImage* standardImage = [[[NSImage alloc] initWithSize:templateImage.size] autorelease];
//    [standardImage lockFocus];
//    [templateImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.5];
//    [standardImage unlockFocus];
//    set_image(standardImage);
//    pressed_image(templateImage);
//}


@interface OakStatusBar ()
- (void)updateLayout;
@end

@implementation OakStatusBar
@synthesize borderEdges;

- (id)initWithFrame:(NSRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		self.postsFrameChangedNotifications = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:self];
		borderEdges = OakStatusBarBorderTop;
		[self updateLayout];
	}
	return self;
}

- (void)viewFrameChanged:(NSNotification*)aNotification
{
	[self updateLayout];
}

- (NSSize)intrinsicContentSize
{
	return NSMakeSize(NSViewNoInstrinsicMetric, OakStatusBarHeight);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

// ==========
// = Layout =
// ==========

- (void)setBorderEdges:(NSInteger)edges
{
	borderEdges = edges;
	[self updateLayout];
}

- (void)setCells: (NSArray *)newCells;
{
	[_cells removeAllObjects];
    
	NSInteger nextTag = NSIntegerMax;
    
	for(OakStatusBarCell *cell in newCells)
	{
		if([cell action] && ![cell tag])
        {
			[cell setTag: nextTag--];
        }
        
		if([cell minSize] == 0)
		{
			if([cell image])
            {
				cell.minSize += [[cell image] size].width;
            }
			if([cell text])
            {
				cell.minSize += WidthOfText([cell text]);
            }
            
			if([cell maxSize] == 0)
            {
				cell.maxSize = cell.minSize;
            }
		}
		if([cell padding] != -1)
		{
			if([cell image])
            {
				[cell setPadding: 3];
                
            }else if([cell text])
            {
				[cell setPadding: 5];
            }
		}
		else
		{
			[cell setPadding: 0];
		}
        
		if([cell type] == OakStatusBarPopup)
		{
			CGFloat arrowsWidth = [[NSImage imageNamed: @"Statusbar Popup Arrows"
                                   inSameBundleAsClass: [OakStatusBar class]] size].width;
			cell.minSize += arrowsWidth;
			if([cell maxSize] != CGFLOAT_MAX)
				cell.maxSize += arrowsWidth;
		}
		else if([cell type] == OakStatusBarDropdown)
		{
			CGFloat arrowWidth = [[NSImage imageNamed: @"Statusbar Dropdown Arrow"
                                  inSameBundleAsClass: [OakStatusBar class]] size].width;
			
            cell.minSize += arrowWidth;
            
			if([cell maxSize] != CGFLOAT_MAX)
            {
				cell.maxSize += arrowWidth;
            }
		}
        
		[_cells addObject: cell];
        
		if(cell != [newCells lastObject] && ![cell skipTrailingSeparator])
		{
			OakStatusBarCell *separator = [[OakStatusBarCell alloc] init];
			[separator setMinSize: 1];
            [separator setMaxSize: 1];
			[separator setImage: [NSImage imageNamed: @"Statusbar Separator"
                                inSameBundleAsClass: [OakStatusBar class]]];
            
			[_cells addObject: separator];
            
            [separator release];
		}
	}
    
	[self updateLayout];
}

//struct cell_layout_t
//{
//    CGFloat x;
//    CGFloat width;
//};

static NSArray* layout (CGFloat frameWidth, NSArray * cells)
{
	CGFloat minWidth = 0, maxWidth = 0;
	for(OakStatusBarCell *it in cells)
	{
		minWidth += [it padding] + [it minSize] + [it padding];
		maxWidth += [it padding] + (([it maxSize] == CGFLOAT_MAX) ? frameWidth : [it maxSize]) + [it padding];
	}
    
	CGFloat available = frameWidth - minWidth;
	CGFloat delta     = maxWidth - minWidth;
    
	NSMutableArray *cellLayout = [NSMutableArray array];
    
	CGFloat x = 0;
	
    for(OakStatusBarCell *it in cells)
	{
		CGFloat width = [it minSize];
		if(minWidth < frameWidth && maxWidth != minWidth)
		{
			CGFloat cellDelta = ([it maxSize] == CGFLOAT_MAX ? frameWidth : [it maxSize]) - [it minSize];
			width += round(available * cellDelta / delta);
		}
		width += [it padding] * 2;
        
		[cellLayout addObject: [NSValue valueWithSize: CGSizeMake(x, width)]];
        
		x += width;
	}
    
	return cellLayout;
}

- (void)updateLayout
{
	NSMutableArray *newLayout = [NSMutableArray array];
    
	NSImage* backgroundImage = [NSImage imageNamed: @"Statusbar Background"
                               inSameBundleAsClass: [OakStatusBar class]];
    
	CGFloat y = 0;
	if(borderEdges & OakStatusBarBorderBottom)
	{
		OakLayer * bottomBorder = [[OakLayer alloc] init];
        
		bottomBorder.rect  = NSMakeRect(0, 0, self.bounds.size.width, 1);
		bottomBorder.color = [NSColor colorWithString:@"#9d9d9d"];
		
        [newLayout addObject: bottomBorder];
        
		y += 1;
	}
    
	OakLayer * background = [[OakLayer alloc] init];
	
    background.rect          = NSMakeRect(0, y, self.bounds.size.width, [backgroundImage size].height);
	background.image         = backgroundImage;
	[background setImageOptions: OakLayerImageStretch];
	[newLayout addObject: background];
    
	y += background.rect.size.height;
    
	if(borderEdges & OakStatusBarBorderTop)
	{
		OakLayer * topBorder = [[OakLayer alloc] init];
		topBorder.rect  = NSMakeRect(0, y, self.bounds.size.width, 1);
		topBorder.color = [NSColor colorWithString:@"#9d9d9d"];
		[newLayout addObject: topBorder];
	}
    
	NSArray *cellLayout = layout(self.bounds.size.width, _cells);
    
	for(NSUInteger cellIndex = 0; cellIndex < [_cells count]; ++cellIndex)
	{
		OakStatusBarCell *cell = [_cells objectAtIndex: cellIndex];
        
        CGSize size = [[cellLayout objectAtIndex: cellIndex] sizeValue];
		CGFloat cellWidth  = size.height;
		CGFloat x          = size.width;
        
		if(cell.image)
		{
			OakLayer * layer = [[OakLayer alloc] init];
            
			CGFloat imageHeight     = [[cell image] size].height;
			CGFloat statusBarHeight = [backgroundImage size].height;
            
			layer.rect = NSMakeRect([cell padding] + x, (borderEdges & OakStatusBarBorderBottom) ? 1 : 0 + round((statusBarHeight - imageHeight) / 2), cellWidth - cell.padding * 2, imageHeight);
			if([cell state] == NSOffState)
			{
				NSImage* disabledImage = [cell disabledImage];
				if(!disabledImage)
				{
					disabledImage = [[[NSImage alloc] initWithSize: [[cell image] size]] autorelease];
                    
					[disabledImage lockFocus];
					
                    [[cell image] drawAtPoint: NSZeroPoint
                                     fromRect: NSZeroRect
                                    operation: NSCompositeSourceOver
                                     fraction: 0.25];
					
                    [disabledImage unlockFocus];
				}
                
				layer.image = disabledImage;
			}
			else
			{
				layer.image = [cell image];
			}
            
			[newLayout addObject: layer];
		}
        
		if([cell text])
		{
			CGFloat offset = cell.padding + x;
			CGFloat width = cellWidth - cell.padding * 2;
			if(cell.image)
			{
				offset += [[cell image] size].width + 1;
				width  -= [[cell image] size].width + 1;
			}
            
			OakLayer * layer = [[OakLayer alloc] init];
            
			CGFloat textHeight = 13;
			layer.rect = NSMakeRect(offset, (borderEdges & OakStatusBarBorderBottom) ? 2 : 1, width, textHeight);
			layer.text =  [cell text];
			[newLayout addObject: layer];
		}
        
		if(cell.view)
		{
			CGFloat y = ((borderEdges & OakStatusBarBorderBottom) ? 1 : 0) + ([backgroundImage size].height - [cell.view frame].size.height) / 2;
			OakLayer * layer = [[OakLayer alloc] init];
			layer.rect = NSMakeRect(cell.padding + x, y, cellWidth - cell.padding * 2, [backgroundImage size].height);
			layer.view = cell.view;
			[newLayout addObject: layer];
		}
        
		if(cell.action)
		{
			if(cell.type == OakStatusBarPopup)
			{
				OakLayer * arrows = [[OakLayer alloc] init];
				arrows.image         = [NSImage imageNamed: @"Statusbar Popup Arrows"
                                       inSameBundleAsClass: [OakStatusBar class]];
                
                CGSize imageSize = [[arrows image] size];
                
                [arrows setRect: NSMakeRect(x + cellWidth - imageSize.width,
                                           (self.frame.size.height - arrows.rect.size.height) + ((borderEdges & OakStatusBarBorderTop) ? 0 : 1)
                                            , imageSize.width, imageSize.height)];
				[newLayout addObject: arrows];
			}
			else if(cell.type == OakStatusBarDropdown)
			{
				OakLayer * arrow = [[OakLayer alloc] init];
				arrow.image         = [NSImage imageNamed: @"Statusbar Dropdown Arrow"
                                      inSameBundleAsClass: [OakStatusBar class]];
                
                CGSize imageSize = [[arrow image] size];

                [arrow setRect: NSMakeRect(x + cellWidth - imageSize.width - 2,
                                          (self.bounds.size.height - arrow.rect.size.height) / 2,
                                           imageSize.width, imageSize.height)];

				[newLayout addObject: arrow];
			}
            
			if(cell.state == NSOnState)
			{
				OakLayer * trigger = [[OakLayer alloc] init];
                
				trigger.rect      = NSMakeRect(x, (borderEdges & OakStatusBarBorderBottom) ? 1 : 0, cellWidth, [backgroundImage size].height);
				trigger.requisite = trigger.requisiteMask = OakLayerMouseDown;
				trigger.action    = cell.action;
				trigger.tag       = cell.tag;
                
				if(cell.type == OakStatusBarButton)
				{
					if(cell.pressedImage)
					{
						CGFloat imageHeight     = [[cell pressedImage] size].height;
						CGFloat statusBarHeight = [backgroundImage size].height;
						[trigger setContentOffset: NSMakePoint(cell.padding, round((statusBarHeight - imageHeight) / 2))];
						trigger.image           = cell.pressedImage;
					}
					else
					{
						trigger.image         = [NSImage imageNamed: @"Statusbar Background Pressed"
                                                inSameBundleAsClass: [OakStatusBar class]];
                        
						trigger.imageOptions = OakLayerImageStretch;
					}
					trigger.requisite  = trigger.requisiteMask = cell.menuAction ? (OakLayerMouseClicked
                                                                                    | OakLayerMenuGesture) : OakLayerMouseClicked;
					trigger.menuAction = cell.menuAction;
				}
                
				[newLayout addObject: trigger];
			}
		}
        
		if([cell toolTip])
		{
			OakLayer * toolTip = [[OakLayer alloc] init];
            
			toolTip.rect     = NSMakeRect(x, (borderEdges & OakStatusBarBorderBottom) ? 1 : 0, cellWidth, [backgroundImage size].height);
			[toolTip setToolTip:  [cell toolTip]];
            
			[newLayout addObject: toolTip];
		}
	}
    
	[self setLayers: newLayout];
	[self setNeedsDisplay: YES];
}

- (CGFloat)minimumWidth
{
	CGFloat minWidth = 0;
	for(OakStatusBarCell *it in _cells)
    {
        minWidth += [it padding] + [it minSize] + [it padding];
    }
    
	return minWidth;
}

// ===========
// = Actions =
// ===========

- (void)sendAction: (SEL)action
         fromLayer: (OakLayer *)aLayer
{
	for(OakStatusBarCell *it in _cells)
	{
		if([it tag] == [aLayer tag])
		{
			[self setTag: [aLayer tag]];
			
            [NSApp sendAction: action
                           to: [it target]
                         from: self];
            
			return;
		}
	}
}

- (void)showMenu: (NSMenu*)menu
withSelectedIndex: (NSUInteger)index
  forCellWithTag: (NSInteger)cellTag
            font: (NSFont*)font
           popup: (BOOL)isPopup
{
	NSRect rect = [self bounds];
    
	// Find the layer with the provided tag
	for(OakLayer  *it in [self layers])
	{
		if([it tag] == cellTag)
		{
			rect = [it rect];
			break;
		}
	}
    
	NSPoint pos       = [[self window] convertBaseToScreen: [self convertPoint: NSMakePoint(0, NSMaxY(rect))
                                                                        toView: nil]];
    
	CGFloat scrBottom = NSMinY([[[self window] screen] visibleFrame]) + 30.0;
	if(pos.y < scrBottom)
    {
		rect.origin.y += 30.0;
    }
    
	[self showMenu: menu
            inRect: rect
 withSelectedIndex: index
              font: font
             popup: isPopup];
}

- (void)rightMouseDown:(NSEvent*)theEvent
{
	[self mouseDown: theEvent];
}
@end
