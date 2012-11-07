#import "NSColor+Additions.h"
#import <OakFoundation/OakFoundation.h>

@implementation NSColor (Creation)

+ (NSColor *)colorWithString: (NSString*)aString
{
	if(aString)
    {
        unsigned int red = 0, green = 0, blue = 0, alpha = 0xFF;
        
        if(sscanf([aString UTF8String], "#%02x%02x%02x%02x", &red, &green, &blue, &alpha) >= 3)
        {
            return [NSColor colorWithCalibratedRed: red/255.0
                                             green: green/255.0
                                              blue: blue/255.0
                                             alpha: alpha/255.0];
        }
        
        SEL sel = NSSelectorFromString(aString);
        
        if([NSColor respondsToSelector: sel])
        {
            return [NSColor performSelector: sel];
        }
    }
    
	return nil;
}

+ (NSColor*)tmColorWithCGColor: (CGColorRef)aColor
{
	if([self respondsToSelector: @selector(colorWithCGColor:)])
    {
		return [self colorWithCGColor: aColor];
    }
	return [NSColor colorWithColorSpace: [[[NSColorSpace alloc] initWithCGColorSpace: CGColorGetColorSpace(aColor)] autorelease]
                             components: CGColorGetComponents(aColor)
                                  count: CGColorGetNumberOfComponents(aColor)];
}

@end

@implementation NSColor (OakColor)

- (BOOL)isDark
{
	long r = lroundf(255 * [self redComponent]);
	long g = lroundf(255 * [self greenComponent]);
	long b = lroundf(255 * [self blueComponent]);
    
	long intensity = r * r * 30 + g * g * 59 + b * b * 11;
	return intensity < 50 * 255 * 255;
}

@end
