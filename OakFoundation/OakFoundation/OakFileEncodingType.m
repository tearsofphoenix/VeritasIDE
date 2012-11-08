//
//  OakFileEncodingType.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakFileEncodingType.h"

@implementation OakFileEncodingType

- (BOOL)byteOrderMarkSupported
{
    return _byteOrderMarkSupported && supports_byte_order_mark(_charsetName);
}

- (void)setCharsetName: (NSString *)charsetName
{
    if(_charsetName != charsetName)
    {
        [_charsetName release];
        _charsetName = [charsetName retain];
        
        _byteOrderMarkSupported = (![_charsetName isEqualToString: kCharsetUTF8]
                                   && supports_byte_order_mark(_charsetName));
    }
}

id OakFileEncodingTypeMake(NSString *newLines, NSString *charsetName, BOOL BOMSupported)
{
    OakFileEncodingType *type = [[OakFileEncodingType alloc] init];
    [type setNewlines: newLines];
    [type setCharsetName: charsetName];
    [type setByteOrderMarkSupported: BOMSupported];
    
    return [type autorelease];
}

@end
