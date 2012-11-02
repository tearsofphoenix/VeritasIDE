/*
 File: VDEImageTextCell.m
 Abstract: Subclass of NSTextFieldCell which can display text and an image simultaneously.
 
 */

#import "VDEImageTextCell.h"

#define kIconImageSize          16.0

#define kImageOriginXOffset     3
#define kImageOriginYOffset     1

#define kTextOriginXOffset      2
#define kTextOriginYOffset      2
#define kTextHeightAdjust       4

@implementation VDEImageTextCell

@synthesize image = _image;

- (id)init
{
	self = [super init];
	if (self)
    {
        // we want a smaller font
        [self setFont:[NSFont systemFontOfSize: [NSFont smallSystemFontSize]]];
        [self setEditable: YES];
    }
	return self;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    VDEImageTextCell *cell = [super copyWithZone:zone];
    [cell setImage: [_image retain]];
    
    return cell;
}

- (void)setImage:(NSImage *)anImage
{
    if (anImage != _image)
	{
        [_image release];
        _image = [anImage retain];
		[_image setSize: NSMakeSize(kIconImageSize, kIconImageSize)];
    }
}

- (BOOL)isGroupCell
{
    return ([self image] == nil && [[self title] length] > 0);
}

// -------------------------------------------------------------------------------
//
//	Returns the proper bound for the cell's title while being edited
// -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
{
	// the cell has an image: draw the normal item cell
	NSSize imageSize;
	NSRect imageFrame;
    
	imageSize = [_image size];
	NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + imageSize.width, NSMinXEdge);
    
	imageFrame.origin.x += kImageOriginXOffset;
	imageFrame.origin.y -= kImageOriginYOffset;
	imageFrame.size = imageSize;
	
	imageFrame.origin.y += ceil((cellRect.size.height - imageFrame.size.height) / 2);
	
	NSRect newFrame = cellRect;
	newFrame.origin.x += kTextOriginXOffset;
	newFrame.origin.y += kTextOriginYOffset;
	newFrame.size.height -= kTextHeightAdjust;
    
	return newFrame;
}

- (void)editWithFrame: (NSRect)aRect
               inView: (NSView*)controlView
               editor: (NSText*)textObj
             delegate: (id)anObject
                event: (NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
    
	[super editWithFrame: textFrame
                  inView: controlView
                  editor: textObj
                delegate: anObject
                   event: theEvent];
}

- (void)selectWithFrame: (NSRect)aRect
                 inView: (NSView *)controlView
                 editor: (NSText *)textObj
               delegate: (id)anObject
                  start: (NSInteger)selStart
                 length: (NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
    
	[super selectWithFrame: textFrame
                    inView: controlView
                    editor: textObj
                  delegate: anObject
                     start: selStart
                    length: selLength];
}

- (void)drawWithFrame: (NSRect)cellFrame
               inView: (NSView*)controlView
{
	if (_image)
	{
        // the cell has an image: draw the normal item cell
        NSSize imageSize;
        NSRect imageFrame;
        
        imageSize = [_image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += kImageOriginXOffset;
        imageFrame.origin.y -= kImageOriginYOffset;
        imageFrame.size = imageSize;
        
        [_image setFlipped: YES];
        [_image drawAtPoint: imageFrame.origin
                   fromRect:  NSZeroRect//NSMakeRect(0, 0, imageFrame.size.width, imageFrame.size.height)
                  operation: NSCompositeSourceOver
                   fraction: 1.0];
        
        NSRect newFrame = cellFrame;
        newFrame.origin.x += kTextOriginXOffset;
        newFrame.origin.y += kTextOriginYOffset;
        newFrame.size.height -= kTextHeightAdjust;
        
        [super drawWithFrame: newFrame
                      inView: controlView];
        
        
    }
	else
	{
		if ([self isGroupCell])
		{
            // Center the text in the cellFrame, and call super to do thew ork of actually drawing.
            //
            CGFloat yOffset = floor((NSHeight(cellFrame) - [[self attributedStringValue] size].height) / 2.0);
            
            cellFrame.origin.y += yOffset;
            cellFrame.size.height -= (kTextOriginYOffset*yOffset);
            
            [super drawWithFrame: cellFrame
                          inView: controlView];
		}
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (_image ? [_image size].width : 0) + 3;
    return cellSize;
}

@end

