//
//  OakFunctions.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakFunctions.h"

NSInteger OakCap(NSInteger min, NSInteger value, NSInteger max)
{
    return (value < min ? min : (value > max ? max : value));
}

double OakSlowInOut (double t)
{
    if(t < 1.0)
    {
        t = 1.0 / (1.0 + exp((-t * 12.0) + 6.0));
    }
    
    return MIN(t, 1.0);
}

NSString * OakStringFromFileSize(NSUInteger inBytes)
{
    double size         = (double)inBytes;
    char const* unitStr = inBytes == 1 ? "byte" : "bytes";
    
    if(inBytes > 1000 * 1024*1024)
    {
        size   /= 1024*1024*1024;
        unitStr = "GiB";
    }
    else if(inBytes > 1000 * 1024)
    {
        size   /= 1024*1024;
        unitStr = "MiB";
    }
    else if(inBytes > 1000)
    {
        size   /= 1024;
        unitStr = "KiB";
    }
    else
    {
        return [NSString stringWithFormat: @"%zu %s", inBytes, unitStr];
    }
    
    return [NSString stringWithFormat: @"%.1f %s", size, unitStr];
}


NSString * OakTextPad(NSUInteger number, NSUInteger minDigits)
{
    NSUInteger actualDigits = 1 + (NSUInteger)floor(log10(number));
    
    NSMutableString * res = [NSMutableString string];
    for(NSUInteger i = 0; i < MAX(minDigits, actualDigits) - actualDigits; ++i)
    {
        [res appendString: @"\u2007"]; // Figure Space
    }
    
    [res appendFormat: @"%zu", number];
    
    return res;
}


CGFloat OakFontSizeFromString(NSString * str)
{
	// Treat positive values as absolute font
	// and negative as relative, that way we don't have to use a bool as a flag :)
	if(str)
	{
        NSUInteger length = [str length];
        
        if ([str hasSuffix: @"pt"])
        {
            return [[str substringWithRange: NSMakeRange(0, length - 2)] doubleValue];
        }
        
        if ([str hasSuffix: @"em"])
        {
            return - [[str substringWithRange: NSMakeRange(0, length - 2)] doubleValue];
        }
        
        if ([str hasSuffix: @"%"])
        {
            return - [[str substringWithRange: NSMakeRange(0, length - 1)] doubleValue];
        }
	}
    
	return -1;
}
