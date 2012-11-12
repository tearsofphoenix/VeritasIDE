//
//  XCTextAnnotationTheme.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-10.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCTextAnnotationTheme.h"

@implementation XCTextAnnotationTheme

static XCTextAnnotationTheme * s_XCClassicBlueTheme = nil;

+ (id)classicBlueTextAnnotationTheme
{
    if (!s_XCClassicBlueTheme)
    {
        s_XCClassicBlueTheme = [[self alloc] init];
    }
    
    return s_XCClassicBlueTheme;
}

static XCTextAnnotationTheme *s_XCBlueGlassTheme = nil;

+ (id)blueGlassTextAnnotationTheme
{
    if (!s_XCBlueGlassTheme)
    {
        s_XCBlueGlassTheme = [[self alloc] init];
    }
    
    return s_XCBlueGlassTheme;
}

static XCTextAnnotationTheme *s_XCRedTheme = nil;

+ (id)redGlassTextAnnotationTheme
{
    if (!s_XCRedTheme)
    {
        s_XCRedTheme = [[self alloc] init];
    }
    
    return s_XCRedTheme;
}

static XCTextAnnotationTheme *s_XCYellowGlassTheme = nil;

+ (id)yellowGlassTextAnnotationTheme
{
    if (s_XCYellowGlassTheme)
    {
        s_XCYellowGlassTheme = [[self alloc] init];
    }
    
    return s_XCYellowGlassTheme;
}

@synthesize highlightBackgroundColor=_highlightBackgroundColor;

@synthesize highlightOutlineColor=_highlightOutlineColor;

@synthesize bottomGradient=_bottomGradient;

@synthesize topGradient=_topGradient;

@synthesize bottomBorderColor=_bottomBorderColor;

@synthesize topBorderColor=_topBorderColor;

@synthesize focusedBackgroundColor=_focusedBackgroundColor;

@synthesize selectedBackgroundColor=_selectedBackgroundColor;

@synthesize backgroundColor=_backgroundColor;

- (void)dealloc
{
    [_highlightBackgroundColor release];
    [_highlightOutlineColor release];
    [_bottomGradient release];
    
    [_topGradient release];
    [_bottomBorderColor release];
    [_topBorderColor release];
    
    [_focusedBackgroundColor release];
    [_selectedBackgroundColor release];
    [_backgroundColor release];
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

@end