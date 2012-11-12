/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@class XCSyntaxTypeSpecification;

enum
{
    NSColorBlackColor = 0,
    NSColorDarkGrayColor,
    NSColorLightGrayColor,
    NSColorWhiteColor,
    NSColorGrayColor,
    NSColorRedColor,
    NSColorGreenColor,
    NSColorBlueColor,
    NSColorCyanColor,
    NSColorYellowColor,
    NSColorMagentaColor,
    NSColorOrangeColor,
    NSColorPurpleColor,
    NSColorBrownColor,
    NSColorClearColor,
};

typedef NSInteger XCColorID;

@interface XCTextColor : NSObject
{
    NSString *_colorName;
    short _colorId;
    NSColor *_color;
    XCSyntaxTypeSpecification *_syntaxType;
}

@property (nonatomic, retain) NSFont *font;
@property (nonatomic, retain) NSColor *color;

- (XCSyntaxTypeSpecification *)syntaxType;
- (NSColor *)defaultColor;

- (short)colorId;

- (NSString *)name;

- (void)dealloc;

- (id)initWithName: (NSString *)name
           colorId: (short)arg2;

@end

