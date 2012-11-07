//
//  NSString+RandomHexString.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-31.
//
//

#import <Foundation/Foundation.h>

extern BOOL VDEGetMacAddress(UInt8 MACAddress[]);

@interface NSString (RandomHexString)

+ (NSString *)randomHexStringWithLength: (NSUInteger)length;

+ (NSString *)randomHexString;

+ (NSString *)fileUUIDString;

+ (NSString *)randomLowerAlphabetStringWithLength: (NSUInteger)length;

@end
