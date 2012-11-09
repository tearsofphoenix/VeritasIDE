//
//  NoodleLineNumberMarker.m
//  Line View Test
//
//  Created by Paul Kim on 9/30/08.
//  Copyright (c) 2008 Noodlesoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "NoodleLineNumberMarker.h"


@implementation NoodleLineNumberMarker

#define CORNER_RADIUS	3.0
#define MARKER_HEIGHT	14.0

static NSImage *s_VDELineNumberMarkerEnableImage = nil;
static NSImage *s_VDELineNumberMarkerDisableImage = nil;

static NSColor *s_VDELineNumberMarkerColor = nil;
static NSColor *s_VDELineNumberMarkerDisableColor = nil;
static NSColor *s_VDELineNumberMarkerFillColor = nil;

+ (void)initialize
{
    s_VDELineNumberMarkerColor = [[NSColor colorWithCalibratedRed: 0.37
                                                           green: 0.56
                                                            blue: 0.77
                                                            alpha: 1.00] retain];
    
    s_VDELineNumberMarkerDisableColor = [[NSColor colorWithCalibratedRed: 0.77
                                                                  green: 0.84
                                                                   blue: 0.91
                                                                   alpha: 1.00] retain];
    
    s_VDELineNumberMarkerFillColor = [[NSColor colorWithCalibratedRed: 0.26
                                                               green: 0.44
                                                                blue: 0.69
                                                                alpha: 1.00] retain];
    
    CGSize size = CGSizeMake(36, MARKER_HEIGHT);
    s_VDELineNumberMarkerEnableImage = [[NSImage alloc] initWithSize: size];
    NSCustomImageRep *rep = [[NSCustomImageRep alloc] initWithDrawSelector: @selector(drawMarkerImageIntoRep:)
                                                                  delegate: self];
    [rep setSize:size];
    [s_VDELineNumberMarkerEnableImage addRepresentation: rep];
    [rep release];
    
    //disable image
    s_VDELineNumberMarkerDisableImage = [[NSImage alloc] initWithSize: size];
    
    NSCustomImageRep *disableRep = [[NSCustomImageRep alloc] initWithDrawSelector: @selector(drawDisabledMarkerImageWithRep:)
                                                                         delegate: self];
    [disableRep setSize: size];
    [s_VDELineNumberMarkerDisableImage addRepresentation: disableRep];
    [disableRep release];
}

static void NLNumerMarkerDraw(NSCustomImageRep *rep, NSColor *fillColor)
{
    NSBezierPath	*path;
	NSRect			rect;
	
	rect = NSMakeRect(1.0, 2.0, [rep size].width - 2.0, [rep size].height - 3.0);
	
	path = [NSBezierPath bezierPath];
	[path moveToPoint: NSMakePoint(NSMaxX(rect), NSMinY(rect) + NSHeight(rect) / 2)];
	[path lineToPoint: NSMakePoint(NSMaxX(rect) - 5.0, NSMaxY(rect))];
	
	[path appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(rect) + CORNER_RADIUS, NSMaxY(rect) - CORNER_RADIUS)
                                     radius: CORNER_RADIUS
                                 startAngle: 90
                                   endAngle: 180];
	
	[path appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(rect) + CORNER_RADIUS, NSMinY(rect) + CORNER_RADIUS)
                                     radius: CORNER_RADIUS
                                 startAngle: 180
                                   endAngle: 270];
    
	[path lineToPoint: NSMakePoint(NSMaxX(rect) - 5.0, NSMinY(rect))];
	[path closePath];
	
    [fillColor set];
    
	[path fill];
	
    [s_VDELineNumberMarkerFillColor set];
	
	[path setLineWidth: 1.0];
    
	[path stroke];
}

+ (void)drawDisabledMarkerImageWithRep: (NSCustomImageRep *)rep
{
	NLNumerMarkerDraw(rep, s_VDELineNumberMarkerDisableColor);
}

+ (void)drawMarkerImageIntoRep: (NSCustomImageRep *)rep
{
	NLNumerMarkerDraw(rep, s_VDELineNumberMarkerColor);
}

@synthesize lineNumber = _lineNumber;

- (id)initWithRulerView: (NSRulerView *)aRulerView
             lineNumber: (NSUInteger)lineNumber
{
	if ((self = [super initWithRulerView: aRulerView
                          markerLocation: 0.0
                                   image: s_VDELineNumberMarkerEnableImage
                             imageOrigin: NSMakePoint(0, MARKER_HEIGHT / 2)]))
	{
        _lineNumber = lineNumber;
	}
	return self;
}

@synthesize enable = _enable;

- (void)setEnable: (BOOL)enable
{
    if (_enable != enable)
    {
        _enable = enable;
        
        if (_enable)
        {
            [self setImage: s_VDELineNumberMarkerEnableImage];
            
        }else
        {
            [self setImage: s_VDELineNumberMarkerDisableImage];
        }
    }
}

#pragma mark - NSCoding methods

#define NOODLE_LINE_CODING_KEY		@"line"

- (id)initWithCoder: (NSCoder *)decoder
{
	if ((self = [super initWithCoder: decoder]))
	{
        _lineNumber = [decoder decodeIntegerForKey: NOODLE_LINE_CODING_KEY];
	}
	return self;
}

- (void)encodeWithCoder: (NSCoder *)encoder
{
	[super encodeWithCoder: encoder];
	
    [encoder encodeInteger: _lineNumber
                    forKey: NOODLE_LINE_CODING_KEY];
}


#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone: zone];
    
	[copy setLineNumber: _lineNumber];
	
	return copy;
}


@end
