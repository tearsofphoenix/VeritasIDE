//
//  GCJumpBarLabel.m
//  GCJumpBarDemo
//
//  Created by Guillaume Campagna on 11-05-24.
//  Copyright 2011 LittleKiwi. All rights reserved.
//

#import "GCJumpBarLabel.h"
#import "NSIndexPath+GCJumpBar.h"

static const CGFloat GCJumpBarLabelMargin = 5.0;

static const NSInteger GCJumpBarLabelAccessoryMenuLabelTag = -1;

@interface GCJumpBarLabel ()

@property (nonatomic, retain) NSMenu* clickedMenu;

- (void)setPropretyOnMenu:(NSMenu *)menu;

@end

@implementation GCJumpBarLabel

@synthesize lastLabel;
@synthesize indexInLevel;
@synthesize delegate = _delegate;

static NSDictionary *s_GCJumpBarLabelAttributes = nil;

+ (void)initialize
{
    NSShadow* highlightShadow = [[NSShadow alloc] init];
    highlightShadow.shadowOffset = CGSizeMake(0, -1.0);
    highlightShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.5];
    highlightShadow.shadowBlurRadius = 0.0;
    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode: NSLineBreakByTruncatingTail];
    
    s_GCJumpBarLabelAttributes = [(@{
                                   NSForegroundColorAttributeName :[NSColor blackColor],
                                   NSShadowAttributeName : highlightShadow,
                                   NSFontAttributeName : [NSFont systemFontOfSize:12.0],
                                   NSParagraphStyleAttributeName : style
                                   }) retain];
    [highlightShadow release];
    [style release];
}

#pragma mark - View subclass

- (BOOL)isFlipped
{
    return YES;
}

- (void)sizeToFit
{
    [super sizeToFit];
    
    CGFloat width = (2 + (_image != nil)) * GCJumpBarLabelMargin;
    
    NSSize textSize = [_text sizeWithAttributes: s_GCJumpBarLabelAttributes];
    width += ceil(textSize.width);
    width += ceil(_image.size.width);
    if (!self.lastLabel) width += 7; //Separator image
    
    NSRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

#pragma mark - Getter/Setters

- (CGFloat)minimumWidth
{
    return GCJumpBarLabelMargin + _image.size.width + (_image != nil) * GCJumpBarLabelMargin + (!self.lastLabel) * 7;
}

@synthesize image = _image;

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage)
    {
        [_image release];
        _image = [newImage retain];
        
        [self setNeedsDisplay];
    }
}

@synthesize text = _text;

- (void)setText: (NSString *)newText
{
    if (_text != newText)
    {
        [_text release];
        _text = [newText retain];
        
        [self setNeedsDisplay];
    }
}

- (NSUInteger)level
{
    return [self tag];
}

- (void)setLevel: (NSUInteger)level
{
    [self setTag: level];
}

#pragma mark - Delegate

@synthesize clickedMenu = _clickedMenu;

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([self isEnabled])
    {
        [self setClickedMenu: [_delegate menuToPresentWhenClickedForJumpBarLabel: self]];
        [self setPropretyOnMenu: _clickedMenu];
        
        CGFloat xPoint = (self.tag == GCJumpBarLabelAccessoryMenuLabelTag ? - 9 : - 16);
        
        [_clickedMenu popUpMenuPositioningItem: [_clickedMenu itemAtIndex: self.indexInLevel]
                                    atLocation: NSMakePoint(xPoint , self.frame.size.height - 4)
                                        inView: self];
    }
}

- (void) menuClicked: (id)sender
{
    NSMenuItem* item = sender;
    NSIndexPath* indexPath = [[[NSIndexPath alloc] init] autorelease];
    
    if (self.tag != GCJumpBarLabelAccessoryMenuLabelTag)
    {
        while (![[_clickedMenu itemArray] containsObject:item])
        {
            indexPath = [indexPath indexPathByAddingIndexInFront:[[item menu] indexOfItem:item]];
            item = [item parentItem];
        }
    }
    
    indexPath = [indexPath indexPathByAddingIndexInFront: [[item menu] indexOfItem:item]];
    
    [_delegate   jumpBarLabel: self
didReceivedClickOnItemAtIndexPath: indexPath];
    
    [self setClickedMenu: nil];
}

#pragma mark - Dawing

- (void)drawRect: (NSRect)dirtyRect
{
    CGFloat baseLeft = 0;
    
    if (self.tag == GCJumpBarLabelAccessoryMenuLabelTag)
    {
        NSImage* separatorImage = [NSImage imageNamed: @"GCJumpBarAccessorySeparator"];
        
        [separatorImage drawAtPoint: NSMakePoint(baseLeft + 1, self.frame.size.height / 2 - separatorImage.size.height / 2)
                           fromRect: NSZeroRect
                          operation: NSCompositeSourceOver
                           fraction: 1.0];
        
        baseLeft += separatorImage.size.width + GCJumpBarLabelMargin;
        
    }else
    {
        baseLeft = GCJumpBarLabelMargin;
    }
    
    if (_image != nil)
    {
        [_image drawAtPoint: NSMakePoint(baseLeft, floor(self.frame.size.height / 2 - _image.size.height / 2))
                   fromRect: NSZeroRect
                  operation: NSCompositeSourceOver
                   fraction: 1.0];
        
        baseLeft += ceil(_image.size.width) + GCJumpBarLabelMargin;
    }
    
    if (_text != nil)
    {
        NSSize textSize = [_text sizeWithAttributes: s_GCJumpBarLabelAttributes];
        CGFloat width = self.frame.size.width - baseLeft - GCJumpBarLabelMargin;
        if (!self.lastLabel && self.tag != GCJumpBarLabelAccessoryMenuLabelTag) width -= 7;
        
        if (width > 0)
        {
            [_text drawInRect: CGRectMake(baseLeft, self.frame.size.height / 2 - textSize.height / 2
                                          , width, textSize.height)
               withAttributes: s_GCJumpBarLabelAttributes];
            
            baseLeft += width + GCJumpBarLabelMargin;
        }
    }
    
    if (!self.lastLabel && self.tag != GCJumpBarLabelAccessoryMenuLabelTag)
    {
        NSImage* separatorImage = [NSImage imageNamed: @"GCJumpBarSeparator"];
        
        [separatorImage drawAtPoint: NSMakePoint(baseLeft, self.frame.size.height / 2 - separatorImage.size.height / 2)
                           fromRect: NSZeroRect
                          operation: NSCompositeSourceOver
                           fraction: 1.0];
    }
}

#pragma mark - Helper

- (void)setPropretyOnMenu: (NSMenu *)menu
{
    for (NSMenuItem* item in [menu itemArray])
    {
        if ([item isEnabled])
        {
            [item setTarget: self];
            [item setAction: @selector(menuClicked:)];
            if ([item hasSubmenu])
            {
                [self setPropretyOnMenu: [item submenu]];
            }
        }
    }
}

@end
