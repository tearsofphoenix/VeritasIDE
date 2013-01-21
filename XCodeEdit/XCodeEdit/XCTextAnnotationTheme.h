/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@interface XCTextAnnotationTheme : NSObject
{
    NSColor *_backgroundColor;
    NSColor *_selectedBackgroundColor;
    NSColor *_focusedBackgroundColor;

    NSColor *_topBorderColor;
    NSColor *_bottomBorderColor;
    NSGradient *_topGradient;
    
    NSGradient *_bottomGradient;
    NSColor *_highlightOutlineColor;
    NSColor *_highlightBackgroundColor;
}

+ (id)classicBlueTextAnnotationTheme;
+ (id)blueGlassTextAnnotationTheme;
+ (id)redGlassTextAnnotationTheme;
+ (id)yellowGlassTextAnnotationTheme;

@property(copy, nonatomic) NSColor *highlightBackgroundColor;

@property(copy, nonatomic) NSColor *highlightOutlineColor; 
@property(copy, nonatomic) NSGradient *bottomGradient; 
@property(copy, nonatomic) NSGradient *topGradient; 
@property(copy, nonatomic) NSColor *bottomBorderColor; 
@property(copy, nonatomic) NSColor *topBorderColor; 
@property(copy, nonatomic) NSColor *focusedBackgroundColor; 
@property(copy, nonatomic) NSColor *selectedBackgroundColor; 
@property(copy, nonatomic) NSColor *backgroundColor; 
- (void)dealloc;
- (id)init;

@end
