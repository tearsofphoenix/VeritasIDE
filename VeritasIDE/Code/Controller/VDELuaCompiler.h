//
//  VDELuaCompiler.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import <Foundation/Foundation.h>

@interface VDELuaCompiler : NSObject

+ (void)compileLuaSourceCode: (NSString *)sourceCode
                toFileAtPath: (NSString *)path;

@end
