//
//  DMTabBar.m
//  DMTabBar - XCode like Segmented Control
//
//  Created by Daniele Margutti on 6/18/12.
//  Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved.
//  Licensed under MIT License
//

#import "DMTabBar.h"

#import "DMTabBarItem.h"

// Gradient applied to the background of the tabBar
// (Colors and gradient from Stephan Michels Softwareentwicklung und Beratung - SMTabBar)

// Border color of the bar

// Default tabBar item width
#define kDMTabBarItemWidth                                  32.0f

@interface DMTabBar()
{
@private
    BOOL _delegateRespondsToWillSelectItemAtIndex;
    BOOL _delegateRespondsToDidSelectItemAtIndex;
    NSMutableArray *_items;
}

@end

@implementation DMTabBar

@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

static NSColor *kDMTabBarGradientColor_Start = nil;
static NSColor *kDMTabBarGradientColor_End = nil;
static NSColor *kDMTabBarBorderColor = nil;

static NSGradient *KDMTabBarGradient = nil;

+ (void)initialize
{
    kDMTabBarGradientColor_Start = [NSColor colorWithCalibratedRed: 0.851f
                                                             green: 0.851f
                                                              blue: 0.851f
                                                             alpha: 1.0f];
    
    kDMTabBarGradientColor_End = [NSColor colorWithCalibratedRed: 0.700f
                                                           green: 0.700f
                                                            blue: 0.700f
                                                           alpha: 1.0f];
    
    kDMTabBarBorderColor = [[NSColor colorWithDeviceWhite: 0.2
                                                   alpha: 1.0f] retain];
    
    KDMTabBarGradient = [[NSGradient alloc] initWithStartingColor: kDMTabBarGradientColor_Start
                                                      endingColor: kDMTabBarGradientColor_End];
}

static void DMTabBarInitialize(DMTabBar *self)
{
    [self setAutoresizesSubviews: YES];
    self->_items = [[NSMutableArray alloc] init];
}

- (id)initWithFrame: (NSRect)frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        DMTabBarInitialize(self);
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        DMTabBarInitialize(self);
    }
    
    return self;
}

- (void)dealloc
{
    [_items release];
    [super dealloc];
}

- (void)drawRect: (NSRect)dirtyRect
{
    // Draw bar gradient
    CGRect bounds = [self bounds];
    [KDMTabBarGradient drawInRect: bounds
                            angle: 90.0];
    
    // Draw drak gray bottom border
    [kDMTabBarBorderColor setStroke];
    [NSBezierPath setDefaultLineWidth: 0.0f];
    [NSBezierPath strokeLineFromPoint: NSMakePoint(NSMinX(bounds), NSMaxY(bounds))
                              toPoint: NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)setDelegate: (id<DMTabBarDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
        _delegateRespondsToWillSelectItemAtIndex = [_delegate respondsToSelector: @selector(tabBar:willSelectItem:atIndex:)];
        _delegateRespondsToDidSelectItemAtIndex = [_delegate respondsToSelector: @selector(tabBar:didSelectItem:atIndex:)];
    }
}

- (void)setDataSource: (id<DMTabBarDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        
        [self reloadData];
    }
}

- (void)reloadData
{
    [_items makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [_items removeAllObjects];
    
    NSUInteger count = [_dataSource numberOfItemInTabBar: self];
    DMTabBarItem *itemLooper = nil;
    
    for (NSUInteger iLooper = 0; iLooper < count ; ++iLooper)
    {
        itemLooper = [_dataSource tabBar: self
                             itemAtIndex: iLooper];
        
        [itemLooper setState: (_selectedIndex == iLooper ? NSOnState : NSOffState)];
        [itemLooper setAction: @selector(_selectTabBarItem:)];
        [itemLooper setTarget: self];

        [_items addObject: itemLooper];
        [self addSubview: itemLooper];
    }
    
    [self resizeSubviewsWithOldSize: [self frame].size];
}

- (void)_selectTabBarItem: (id)sender
{
    NSUInteger idx = [_items indexOfObject: sender];
    [self setSelectedIndex: idx];
}

#pragma mark - Layout Subviews

- (void)resizeSubviewsWithOldSize: (NSSize)oldSize
{
    [super resizeSubviewsWithOldSize: oldSize];
    
    NSUInteger buttonsNumber = [_items count];
    CGFloat totalWidth = (buttonsNumber * kDMTabBarItemWidth);
    CGRect bounds = [self bounds];
    
    __block CGFloat offset_x = floorf((NSWidth(bounds)-totalWidth)/2.0f);
    [_items enumerateObjectsUsingBlock: (^(DMTabBarItem* tabBarItem, NSUInteger idx, BOOL *stop)
                                       {
                                           [tabBarItem setFrame: NSMakeRect(offset_x, NSMinY(bounds), kDMTabBarItemWidth, NSHeight(bounds))];
                                           offset_x += kDMTabBarItemWidth;
                                       })];
}

- (void)setSelectedIndex: (NSUInteger)newSelectedIndex
{
    if (newSelectedIndex != _selectedIndex
        && newSelectedIndex < [_items count])
    {
        DMTabBarItem *item = [_items objectAtIndex: newSelectedIndex];
        
        if (_delegateRespondsToWillSelectItemAtIndex)
        {
            [_delegate tabBar: self
               willSelectItem: item
                      atIndex: newSelectedIndex];
        }

        _selectedIndex = newSelectedIndex;
        [_items enumerateObjectsUsingBlock: (^(DMTabBarItem *itemLooper, NSUInteger idx, BOOL *stop)
                                             {
                                                 [itemLooper setState: ((idx == newSelectedIndex) ? NSOnState : NSOffState)];
                                             })];
        
        if (_delegateRespondsToDidSelectItemAtIndex)
        {
            [_delegate tabBar: self
                didSelectItem: item
                      atIndex: newSelectedIndex];
        }

    }
}

- (DMTabBarItem *)selectedTabBarItem
{
    return CFArrayGetValueAtIndex((CFArrayRef)_items, _selectedIndex);
}

@end
