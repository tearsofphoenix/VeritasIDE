//
//  DMTabBarItem.m
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMTabBarItem.h"

@interface DMTabBarButtonCell : NSButtonCell

@end

static CGFloat kDMTabBarItemGradientColor_Locations[] = {0.0f, 0.5f, 1.0f};


@implementation DMTabBarItem

static NSGradient *kDMTabBarItemGradient = nil;
static NSColor *kDMTabBarItemGradientColor1 = nil;
static NSColor *kDMTabBarItemGradientColor2 = nil;

+ (void)initialize
{
    kDMTabBarItemGradientColor1 = [NSColor colorWithCalibratedWhite: 0.7f
                                                              alpha: 0.0f];
    
    kDMTabBarItemGradientColor2 = [NSColor colorWithCalibratedWhite: 0.7f
                                                              alpha: 1.0f];

    kDMTabBarItemGradient = [[NSGradient alloc] initWithColors: @[
                                                                 kDMTabBarItemGradientColor1,
                                                                 kDMTabBarItemGradientColor2,
                                                                 kDMTabBarItemGradientColor1 ]
                                                   atLocations: kDMTabBarItemGradientColor_Locations
                                                    colorSpace: [NSColorSpace genericGrayColorSpace]];
}

static void DMTabBarItemInitialize(DMTabBarItem *self)
{
    DMTabBarButtonCell *cell = [[DMTabBarButtonCell alloc] init];
    [self setCell: cell];
    [cell release];
    
    [self sendActionOn: NSLeftMouseDownMask];
}

- (id)initWithFrame: (NSRect)frameRect
{
    self = [super initWithFrame: frameRect];
    if (self)
    {
        DMTabBarItemInitialize(self);
    }
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        DMTabBarItemInitialize(self);
    }
    
    return self;
}

@end


#pragma mark - DMTabBarButtonCell

@implementation DMTabBarButtonCell

- (id)init
{
    if ((self = [super init]))
    {
        [self setBezelStyle: NSTexturedRoundedBezelStyle];
    }
    return self;
}

- (NSInteger)nextState
{
    return [self state];
}

- (void) drawBezelWithFrame: (NSRect)frame
                     inView: (NSView *)controlView
{
    if ([self state] == NSOnState)
    {
        
        // If selected we need to draw the border new background for selection (otherwise we will use default back color)
        // Save current context
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        // Draw light vertical gradient
        [kDMTabBarItemGradient drawInRect: frame
                                    angle: -90.0f];
        
        // Draw shadow on the left border of the item
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = NSMakeSize(1.0f, 0.0f);
        shadow.shadowBlurRadius = 2.0f;
        shadow.shadowColor = [NSColor darkGrayColor];
        [shadow set];
        
        [[NSColor blackColor] set];        
        CGFloat radius = 50.0;
        NSPoint center = NSMakePoint(NSMinX(frame) - radius, NSMidY(frame));
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter: center
                                         radius: radius
                                     startAngle: -90.0f
                                       endAngle: 90.0f];
        [path closePath];
        [path fill];
        
        // shadow of the right border
        shadow.shadowOffset = NSMakeSize(-1.0f, 0.0f);
        [shadow set];
        [shadow release];
        
        center = NSMakePoint(NSMaxX(frame) + radius, NSMidY(frame));
        path = [NSBezierPath bezierPath];
        [path moveToPoint:center];
        [path appendBezierPathWithArcWithCenter: center
                                         radius: radius
                                     startAngle: 90.0f
                                       endAngle: 270.0f];
        [path closePath];
        [path fill];
        
        // Restore context
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

@end
