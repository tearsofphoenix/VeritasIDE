//
//  OakLayoutContext.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSImage *(* OakImageFoldingFunction) (CGFloat width, CGFloat height);

@interface OakLayoutContext : NSObject
{
    NSMutableDictionary *_imageCache;
}

@property (nonatomic, retain) NSImage *spellingDotImage;

@property (nonatomic, assign) CGContextRef context;

@property (nonatomic) OakImageFoldingFunction foldingFunction;

- (NSImage *)foldingDotsWithSize: (CGSize)size;

@end
