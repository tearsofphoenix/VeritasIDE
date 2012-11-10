//
//  NoodleLineNumberView.m
//  Line View Test
//
//  Created by Paul Kim on 9/28/08.
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

#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"

#define RULER_MARGIN		5.0

#define NOODLE_Width_CODING_KEY				@"width"
#define NOODLE_FONT_CODING_KEY				@"font"
#define NOODLE_TEXT_COLOR_CODING_KEY		@"textColor"
#define NOODLE_ALT_TEXT_COLOR_CODING_KEY	@"alternateTextColor"
#define NOODLE_BACKGROUND_COLOR_CODING_KEY	@"backgroundColor"

@interface NoodleLineNumberView (Private)

- (NSMutableIndexSet *)lineIndices;

- (void)calculateLines;

- (NSUInteger)lineNumberForCharacterIndex: (NSUInteger)index
                                   inText: (NSString *)text;
+ (NSDictionary *)textAttributes;

+ (NSDictionary *)markerTextAttributes;

@end

@implementation NoodleLineNumberView

static NSMutableDictionary * s_defaultConfiguration = nil;

+ (void)initialize
{
    
    if(!s_defaultConfiguration)
    {
        s_defaultConfiguration = [[NSMutableDictionary alloc] initWithDictionary:
                                  (@{
                                   NOODLE_Width_CODING_KEY : @36.0,
                                   NOODLE_FONT_CODING_KEY : [NSFont labelFontOfSize: [NSFont systemFontSizeForControlSize:NSMiniControlSize]],
                                   NOODLE_TEXT_COLOR_CODING_KEY : [NSColor colorWithCalibratedWhite: 0.42
                                                                                              alpha: 1.0],
                                   NOODLE_ALT_TEXT_COLOR_CODING_KEY : [NSColor whiteColor],
                                   NOODLE_BACKGROUND_COLOR_CODING_KEY : [NSColor colorWithCalibratedRed: 0.95
                                                                                                  green: 0.95
                                                                                                   blue: 0.95
                                                                                                  alpha: 1.00],
                                   })];
    }
    
}

#pragma mark - configuration

+ (void)setDefaultWidth: (CGFloat)width
{
    [s_defaultConfiguration setObject: @(width)
                               forKey: NOODLE_Width_CODING_KEY];
}

+ (CGFloat)defaultWidth
{
    return [[s_defaultConfiguration objectForKey: NOODLE_Width_CODING_KEY] doubleValue];
}

//font
//
+ (void)setTextFont: (NSFont *)font
{
    [s_defaultConfiguration setObject: font
                               forKey: NOODLE_FONT_CODING_KEY];
}

+ (NSFont *)textFont
{
    return [s_defaultConfiguration objectForKey: NOODLE_FONT_CODING_KEY];
}

//textColor
//
+ (void)setTextColor: (NSColor *)textColor
{
    [s_defaultConfiguration setObject: textColor
                               forKey: NOODLE_TEXT_COLOR_CODING_KEY];
}

+ (NSColor *)textColor
{
    return [s_defaultConfiguration objectForKey: NOODLE_TEXT_COLOR_CODING_KEY];
}

//alternateTextColor
//
+ (void)setAlternateTextColor: (NSColor *)alternateTextColor
{
    [s_defaultConfiguration setObject: alternateTextColor
                               forKey: NOODLE_ALT_TEXT_COLOR_CODING_KEY];
}

+ (NSColor *)alternateTextColor
{
    return [s_defaultConfiguration objectForKey: NOODLE_ALT_TEXT_COLOR_CODING_KEY];
}

//backgroundColor
//
+ (void)setBackgroundColor: (NSColor *)backgroundColor
{
    [s_defaultConfiguration setObject: backgroundColor
                               forKey: NOODLE_BACKGROUND_COLOR_CODING_KEY];
}

+ (NSColor *)backgroundColor
{
    return [s_defaultConfiguration objectForKey: NOODLE_BACKGROUND_COLOR_CODING_KEY];
}

#pragma mark - methods

- (id)initWithScrollView: (NSScrollView *)aScrollView
{
    if ((self = [super initWithScrollView: aScrollView
                              orientation: NSVerticalRuler]) != nil)
    {
        _lineIndices = [[NSMutableIndexSet alloc] init];
		_linesToMarkers = [[NSMutableDictionary alloc] initWithCapacity: 128];
		
        [self setClientView: [aScrollView documentView]];
    }
    return self;
}

- (void)awakeFromNib
{
	_linesToMarkers = [[NSMutableDictionary alloc] init];
	[self setClientView: [[self scrollView] documentView]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [_lineIndices release];
	[_linesToMarkers release];
    
    [super dealloc];
}

- (void)setClientView: (NSView *)aView
{
	id oldClientView = [self clientView];
	
    if (oldClientView != aView)
    {
		[[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSTextStorageDidProcessEditingNotification
                                                      object: [(NSTextView *)oldClientView textStorage]];
        
        [super setClientView: aView];
        
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(textDidChange:)
                                                     name: NSTextStorageDidProcessEditingNotification
                                                   object: [(NSTextView *)aView textStorage]];
        
        _lineIndicesIsValid = NO;
    }
}

- (NSMutableIndexSet *)lineIndices
{
	if (!_lineIndicesIsValid)
	{
		[self calculateLines];
        
        _lineIndicesIsValid = YES;
	}
    
	return _lineIndices;
}

- (void)textDidChange: (NSNotification *)notification
{
	// Invalidate the line indices. They will be recalculated and recached on demand.
    _lineIndicesIsValid = NO;
    
    CGFloat oldThickness = [self ruleThickness];
    CGFloat newThickness = [self requiredThickness];
    
    if (fabs(oldThickness - newThickness) > 1)
    {
        // Not a good idea to resize the view during calculations (which can happen during
        // display). Do a delayed perform (using NSInvocation since arg is a float).
        [self setRuleThickness: newThickness];
    }
    
    [self setNeedsDisplay: YES];
}

- (NSUInteger)lineNumberForLocation: (CGFloat)location
{
	id view = [self clientView];
	NSRect visibleRect = [[[self scrollView] contentView] bounds];
	
	NSMutableIndexSet *lines = [self lineIndices];
    
	location += NSMinY(visibleRect);
	
    NSRange nullRange = NSMakeRange(NSNotFound, 0);
    
    NSLayoutManager *layoutManager = [view layoutManager];
    NSTextContainer *container = [view textContainer];
    
    __block NSUInteger rectCount;
    __block NSUInteger returnValue = NSNotFound;
    __block NSUInteger lineCount = 0;
    
    [lines enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                        {
                                            NSRectArray rects = [layoutManager rectArrayForCharacterRange: NSMakeRange(idx, 0)
                                                                             withinSelectedCharacterRange: nullRange
                                                                                          inTextContainer: container
                                                                                                rectCount: &rectCount];
                                            
                                            for (NSUInteger i = 0; i < rectCount; i++)
                                            {
                                                if ((location >= NSMinY(rects[i])) && (location < NSMaxY(rects[i])))
                                                {
                                                    returnValue = lineCount + 1;
                                                    *stop = YES;
                                                }
                                            }
                                            ++lineCount;
                                        })];
    
	return returnValue;
}

- (NoodleLineNumberMarker *)markerAtLine: (NSUInteger)line
{
	return [_linesToMarkers objectForKey: @(line - 1)];
}


- (void)calculateLines
{
    [_lineIndices removeAllIndexes];
    
    NSString *text = [(NSTextView *)[self clientView] string];
    NSUInteger stringLength = [text length];
    
    
    NSUInteger index = 0;
    do
    {
        [_lineIndices addIndex: index];
        
        index = NSMaxRange([text lineRangeForRange: NSMakeRange(index, 0)]);
        
    }while (index < stringLength);
    
    // Check if text ends with a new line.
    //
    NSUInteger lineEnd, contentEnd;
    
    [text getLineStart: NULL
                   end: &lineEnd
           contentsEnd: &contentEnd
              forRange: NSMakeRange([_lineIndices lastIndex], 0)];
    
    if (contentEnd < lineEnd)
    {
        [_lineIndices addIndex: index];
    }
}

- (NSUInteger)lineNumberForCharacterIndex: (NSUInteger)index
                                   inText: (NSString *)text
{
	NSMutableIndexSet	* lines = [self lineIndices];
	__block NSUInteger lineNumber = 0;
    [lines enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                        {
                                            if (idx > index)
                                            {
                                                *stop = YES;
                                            }
                                            
                                            ++lineNumber;
                                            
                                        })];

    return lineNumber;
}

+ (NSDictionary *)textAttributes
{
    return (@{
            NSFontAttributeName : [self textFont],
            NSForegroundColorAttributeName : [self textColor]
            });
}

+ (NSDictionary *)markerTextAttributes
{
    return (@{
            NSFontAttributeName : [self textFont],
            NSForegroundColorAttributeName:[self alternateTextColor]
            });
}

- (CGFloat)requiredThickness
{
    NSUInteger lineCount = _lineIndicesIsValid ? [[self lineIndices] count] : 128;
    NSUInteger digits = (NSUInteger)log10(lineCount) + 1;
	NSMutableString     *sampleString = [NSMutableString string];
    
    for (NSUInteger i = 0; i < digits; i++)
    {
        // Use "8" since it is one of the fatter numbers. Anything but "1"
        // will probably be ok here. I could be pedantic and actually find the fattest
		// number for the current font but nah.
        [sampleString appendString:@"8"];
    }
    
    NSSize stringSize = [sampleString sizeWithAttributes: [[self class] textAttributes]];
    
	// Round up the value. There is a bug on 10.4 where the display gets all wonky when scrolling if you don't
	// return an integral value here.
    return ceilf(MAX([[self class] defaultWidth], stringSize.width + RULER_MARGIN * 2));
}

- (void)drawHashMarksAndLabelsInRect: (NSRect)aRect
{
	NSRect	bounds  = [self bounds];
    
	if ([[self class] backgroundColor])
	{
		[[[self class] backgroundColor] set];
		NSRectFill(bounds);
		
		[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] set];
		[NSBezierPath strokeLineFromPoint: NSMakePoint(NSMaxX(bounds) - 0/5,
                                                       NSMinY(bounds))
                                  toPoint: NSMakePoint(NSMaxX(bounds) - 0.5,
                                                       NSMaxY(bounds))];
	}
	
    id view = [self clientView];
	
    
    NSLayoutManager *layoutManager = [view layoutManager];
    NSTextContainer *container = [view textContainer];
    NSString *text = [view string];
    NSRange nullRange = NSMakeRange(NSNotFound, 0);
    
    CGFloat yinset = [view textContainerInset].height;
    NSRect visibleRect = [[[self scrollView] contentView] bounds];
    
    NSDictionary *textAttributes = [[self class] textAttributes];
    
    NSMutableIndexSet *lines = [self lineIndices];
    
    // Find the characters that are currently visible
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect: visibleRect
                                                  inTextContainer: container];
    NSRange range = [layoutManager characterRangeForGlyphRange: glyphRange
                                              actualGlyphRange: NULL];
    
    // Fudge the range a tad in case there is an extra new line at end.
    // It doesn't show up in the glyphs so would not be accounted for.
    range.length++;
    
    NSUInteger line = [self lineNumberForCharacterIndex: range.location
                                                 inText: text];
    [lines enumerateIndexesInRange: NSMakeRange(line, [lines count])
                           options: 0
                        usingBlock: (^(NSUInteger idx, BOOL *stop)
                                     {
                                         
                                         NSUInteger rectCount;
                                         NSRectArray rects;
                                         
                                         if (NSLocationInRange(idx, range))
                                         {
                                             rects = [layoutManager rectArrayForCharacterRange: NSMakeRange(idx, 0)
                                                                  withinSelectedCharacterRange: nullRange
                                                                               inTextContainer: container
                                                                                     rectCount: &rectCount];
                                             
                                             if (rectCount > 0)
                                             {
                                                 // Note that the ruler view is only as tall as the visible
                                                 // portion. Need to compensate for the clipview's coordinates.
                                                 CGFloat ypos = yinset + NSMinY(rects[0]) - NSMinY(visibleRect);
                                                 
                                                 NoodleLineNumberMarker *marker = [_linesToMarkers objectForKey: @(line)];
                                                 
                                                 if (marker)
                                                 {
                                                     //CGFloat originX = 8;
                                                     NSImage *markerImage = [marker image];
                                                     NSSize markerSize = [markerImage size];
                                                     NSRect markerRect = NSMakeRect(0.0, 0.0, markerSize.width, markerSize.height);
                                                     
                                                     // Marker is flush right and centered vertically within the line.
                                                     markerRect.origin.x = NSWidth(bounds) - [markerImage size].width - 1.0;
                                                     markerRect.origin.y = ypos + NSHeight(rects[0]) / 2.0 - [marker imageOrigin].y;
                                                     
                                                     CGRect rect = markerRect;
                                                     rect.origin.x += 2;
                                                     rect.size.width -= 2;
                                                     
                                                     [markerImage drawInRect: rect
                                                                    fromRect: NSMakeRect(0, 0, markerSize.width, markerSize.height)
                                                                   operation: NSCompositeSourceOver
                                                                    fraction: 1.0];
                                                 }
                                                 
                                                 // Line numbers are internally stored starting at 0
                                                 NSString *labelText = [NSString stringWithFormat: @"%ld", line + 1];
                                                 
                                                 NSSize stringSize = [labelText sizeWithAttributes:textAttributes];
                                                 
                                                 NSDictionary * currentTextAttributes = (marker ? textAttributes :  [[self class] markerTextAttributes]);
                                                 
                                                 // Draw string flush right, centered vertically within the line
                                                 [labelText drawInRect: NSMakeRect(NSWidth(bounds) - stringSize.width - RULER_MARGIN,
                                                                                   ypos + (NSHeight(rects[0]) - stringSize.height) / 2.0,
                                                                                   NSWidth(bounds) - RULER_MARGIN * 2.0,
                                                                                   NSHeight(rects[0]))
                                                        withAttributes: currentTextAttributes];
                                             }
                                         }
                                         
                                         if (idx > NSMaxRange(range))
                                         {
                                             *stop = YES;
                                         }
                                     })];
}

- (void)addMarker: (NSRulerMarker *)aMarker
{
    
    [_linesToMarkers setObject: aMarker
                        forKey: @([(NoodleLineNumberMarker *)aMarker lineNumber] - 1)];
    
    [super addMarker: aMarker];
}

- (void)removeMarker: (NSRulerMarker *)aMarker
{
    
    [_linesToMarkers removeObjectForKey: @([(NoodleLineNumberMarker *)aMarker lineNumber] - 1)];
    
    [super removeMarker: aMarker];
}

#pragma mark - NSCoding methods


- (id)initWithCoder: (NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		_linesToMarkers = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@end
