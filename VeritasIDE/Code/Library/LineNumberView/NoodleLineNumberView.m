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

- (NSMutableArray *)lineIndices;

- (void)invalidateLineIndices;

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

- (id)initWithScrollView: (NSScrollView *)aScrollView
{
    if ((self = [super initWithScrollView: aScrollView
                              orientation: NSVerticalRuler]) != nil)
    {
		_linesToMarkers = [[NSMutableDictionary alloc] init];
		
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
	
    if ((oldClientView != aView) && [oldClientView isKindOfClass: [NSTextView class]])
    {
		[[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSTextStorageDidProcessEditingNotification
                                                      object: [(NSTextView *)oldClientView textStorage]];
    }
    
    [super setClientView: aView];
    
    if ((aView != nil) && [aView isKindOfClass: [NSTextView class]])
    {
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(textDidChange:)
                                                     name: NSTextStorageDidProcessEditingNotification
                                                   object: [(NSTextView *)aView textStorage]];
        
		[self invalidateLineIndices];
    }
}

- (NSMutableArray *)lineIndices
{
	if (!_lineIndices)
	{
		[self calculateLines];
	}
	return _lineIndices;
}

- (void)invalidateLineIndices
{
	[_lineIndices release];
	_lineIndices = nil;
}

- (void)textDidChange: (NSNotification *)notification
{
	// Invalidate the line indices. They will be recalculated and recached on demand.
	[self invalidateLineIndices];
	
    [self setNeedsDisplay: YES];
}

- (NSUInteger)lineNumberForLocation: (CGFloat)location
{
	id view = [self clientView];
	NSRect visibleRect = [[[self scrollView] contentView] bounds];
	
	NSMutableArray *lines = [self lineIndices];
    
	location += NSMinY(visibleRect);
	
	if ([view isKindOfClass:[NSTextView class]])
	{
		NSRange nullRange = NSMakeRange(NSNotFound, 0);
        
		NSLayoutManager *layoutManager = [view layoutManager];
		NSTextContainer *container = [view textContainer];
		NSUInteger count = [lines count];
		
        NSUInteger rectCount;
        NSUInteger index;
        
		for (NSUInteger line = 0; line < count; line++)
		{
			index = [[lines objectAtIndex: line] unsignedIntegerValue];
			
			NSRectArray rects = [layoutManager rectArrayForCharacterRange: NSMakeRange(index, 0)
                                             withinSelectedCharacterRange: nullRange
                                                          inTextContainer: container
                                                                rectCount: &rectCount];
			
			for (NSUInteger i = 0; i < rectCount; i++)
			{
				if ((location >= NSMinY(rects[i])) && (location < NSMaxY(rects[i])))
				{
					return line + 1;
				}
			}
		}
	}
	return NSNotFound;
}

- (NoodleLineNumberMarker *)markerAtLine: (NSUInteger)line
{
	return [_linesToMarkers objectForKey: @(line - 1)];
}


- (void)calculateLines
{
    id view = [self clientView];
    
    if ([view isKindOfClass: [NSTextView class]])
    {
        
        NSString *text = [view string];
        NSUInteger stringLength = [text length];
        
        [_lineIndices release];
        _lineIndices = [[NSMutableArray alloc] init];
        
        NSUInteger index = 0;
        NSUInteger numberOfLines = 0;
        
        do
        {
            [_lineIndices addObject: @(index)];
            
            index = NSMaxRange([text lineRangeForRange: NSMakeRange(index, 0)]);
            numberOfLines++;
            
        }while (index < stringLength);
        
        // Check if text ends with a new line.
        //
        NSUInteger lineEnd, contentEnd;

        [text getLineStart: NULL
                       end: &lineEnd
               contentsEnd: &contentEnd
                  forRange: NSMakeRange([[_lineIndices lastObject] unsignedIntValue], 0)];
        if (contentEnd < lineEnd)
        {
            [_lineIndices addObject: @(index)];
        }
        
        CGFloat oldThickness = [self ruleThickness];
        CGFloat newThickness = [self requiredThickness];
        
        if (fabs(oldThickness - newThickness) > 1)
        {
			// Not a good idea to resize the view during calculations (which can happen during
			// display). Do a delayed perform (using NSInvocation since arg is a float).
            
            int64_t delayInSeconds = 0.01;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime,
                           dispatch_get_main_queue(),
                           (^(void)
                            {
                                [self setRuleThickness: newThickness];
                            }));
        }
	}
}

- (NSUInteger)lineNumberForCharacterIndex: (NSUInteger)index
                                   inText: (NSString *)text
{
	NSMutableArray	* lines = [self lineIndices];
	
    // Binary search
    NSUInteger left = 0;
    NSUInteger right = [lines count];

    NSUInteger  mid, lineStart;

    while ((right - left) > 1)
    {
        mid = (right + left) / 2;
        lineStart = [[lines objectAtIndex:mid] unsignedIntValue];
        
        if (index < lineStart)
        {
            right = mid;
        }
        else if (index > lineStart)
        {
            left = mid;
        }
        else
        {
            return mid;
        }
    }
    return left;
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

    NSUInteger lineCount = [[self lineIndices] count];
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
	
    if ([view isKindOfClass:[NSTextView class]])
    {        
        NSLayoutManager *layoutManager = [view layoutManager];
        NSTextContainer *container = [view textContainer];
        NSString *text = [view string];
        NSRange nullRange = NSMakeRange(NSNotFound, 0);
		
        CGFloat yinset = [view textContainerInset].height;
        NSRect visibleRect = [[[self scrollView] contentView] bounds];
        
        NSDictionary *textAttributes = [[self class] textAttributes];
		
		NSMutableArray *lines = [self lineIndices];
        
        // Find the characters that are currently visible
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
        NSRange range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        
        // Fudge the range a tad in case there is an extra new line at end.
        // It doesn't show up in the glyphs so would not be accounted for.
        range.length++;
        
        NSUInteger count = [lines count];
        
        for (NSUInteger line = [self lineNumberForCharacterIndex: range.location
                                               inText: text]; line < count; line++)
        {
            NSUInteger index = [[lines objectAtIndex:line] unsignedIntValue];
            
            NSUInteger rectCount;
            NSRectArray rects;
            
            if (NSLocationInRange(index, range))
            {
                rects = [layoutManager rectArrayForCharacterRange: NSMakeRange(index, 0)
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
            
			if (index > NSMaxRange(range))
			{
				break;
			}
        }
    }
}

- (void)setMarkers: (NSArray *)markers
{
	[_linesToMarkers removeAllObjects];
    
	[super setMarkers: nil];
    
    for (NSRulerMarker *markerLooper in markers)
    {
        [self addMarker: markerLooper];
    }
}

- (void)addMarker:(NSRulerMarker *)aMarker
{
	if ([aMarker isKindOfClass:[NoodleLineNumberMarker class]])
	{
		[_linesToMarkers setObject: aMarker
							forKey: @([(NoodleLineNumberMarker *)aMarker lineNumber] - 1)];
	}
	else
	{
		[super addMarker: aMarker];
	}
}

- (void)removeMarker: (NSRulerMarker *)aMarker
{
	if ([aMarker isKindOfClass: [NoodleLineNumberMarker class]])
	{
		[_linesToMarkers removeObjectForKey: @([(NoodleLineNumberMarker *)aMarker lineNumber] - 1)];
        
	}else
	{
		[super removeMarker: aMarker];
	}
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
