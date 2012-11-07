//
//  OakFileEncodingType.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kCharsetNoEncoding @""
#define  kCharsetASCII      @"ASCII"
#define  kCharsetUTF8       @"UTF-8"
#define  kCharsetUTF16BE    @"UTF-16BE"
#define  kCharsetUTF16LE    @"UTF-16LE"
#define  kCharsetUTF32BE    @"UTF-32BE"
#define  kCharsetUTF32LE    @"UTF-32LE"
#define  kCharsetUnknown    @"UNKNOWN"

@interface OakFileEncodingType : NSObject

@property (nonatomic, retain) NSString *newLines;

@property (nonatomic, retain) NSString *charsetName;

@property (nonatomic) BOOL byteOrderMarkSupported;

@end

extern id OakFileEncodingTypeMake(NSString *newLines, NSString *charsetName, BOOL BOMSupported);

static BOOL supports_byte_order_mark (NSString * charset)
{
    static NSArray *Encodings = @[ kCharsetUTF8, kCharsetUTF16BE, kCharsetUTF16LE, kCharsetUTF32BE, kCharsetUTF32LE ];
    return [Encodings containsObject: charset];
}
