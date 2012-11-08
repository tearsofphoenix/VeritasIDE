//
//  OakLayoutMetrics.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakLayoutMetrics : NSObject

@property (nonatomic)       CGFloat ascent;
@property (nonatomic)       CGFloat descent;
@property (nonatomic)       CGFloat leading;
@property (nonatomic)       CGFloat xHeight;
@property (nonatomic)       CGFloat capHeight;
@property (nonatomic)       CGFloat columnWidth;
    
@property (nonatomic)       CGFloat ascentDelta;
@property (nonatomic)       CGFloat leadingDelta;

- (id)initWithFontName: (NSString *)fontName
              fontSize: (CGFloat)size;

- (CGFloat)baseline: (CGFloat)minAscent;

- (CGFloat)lineHeightWithMinAscent: (CGFloat) minAscent
                        minDescent: (CGFloat) minDescent
                        minLeading: (CGFloat) minLeading;

@end
