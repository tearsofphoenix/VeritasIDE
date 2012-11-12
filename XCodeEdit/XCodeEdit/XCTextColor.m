//
//  XCTextColor.m
//  XcodeEdit
//
//  Created by tearsofphoenix on 12-11-10.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCTextColor.h"

@implementation XCTextColor

@synthesize font = _font;
@synthesize color = _color;

- (XCSyntaxTypeSpecification *)syntaxType
{
    return _syntaxType;
}

- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (short)colorId
{
    return _colorId;
}

- (NSString *)name
{
    return _colorName;
}

- (void)dealloc
{
    [_colorName release];
    [_font release];
    [_color release];
    
    [super dealloc];
}

- (id)initWithName: (NSString *)name
           colorId: (short)arg2
{
    if ((self = [super init]))
    {
        _colorName = [name retain];
        _colorId = arg2;
    }
    
    return self;
}

@end