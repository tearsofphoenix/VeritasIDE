//
//  OakFunctions.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-6.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger OakCap(NSInteger min, NSInteger value, NSInteger max);

extern double OakSlowInOut (double t);

extern NSString * OakStringFromFileSize(NSUInteger inBytes);

extern NSString * OakTextPad(NSUInteger number, NSUInteger minDigits);

extern CGFloat OakSquare(CGFloat v);

#define OakRenderFillRect(context, color, rect) do \
                                                {\
                                                    assert((color));\
                                                    CGContextSetFillColorWithColor((context), (color));\
                                                    CGContextFillRect((context), (rect));\
                                                } while ( 0 )

#define OakLogErrorContent(error, content) do\
                                            {\
                                                NSLog(@"in func: %s error: %@ content: %@", __func__, (error), (content));\
                                            } while ( 0 )


#define OakLogError(error) OakLogErrorContent(error, nil)
