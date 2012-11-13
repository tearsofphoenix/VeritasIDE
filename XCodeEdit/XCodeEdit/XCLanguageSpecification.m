//
//  XCLanguageSpecification.m
//  XCodeEdit
//
//  Created by tearsofphoenix on 12-11-13.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCLanguageSpecification.h"

static NSArray *s_XCLanguageIDs = nil;

@implementation XCLanguageSpecification

+ (void)initialize
{
    if (!s_XCLanguageIDs)
    {
        s_XCLanguageIDs = [@[
                           @"xcode.lang.Ada",
                           @"xcode.lang.ARMAsm",
                           @"xcode.lang.C",
                           @"xcode.lang.CPP",
                           @"xcode.lang.csh",
                           @"xcode.lang.CSS",
                           @"xcode.lang.D",
                           @"xcode.lang.DTrace",
                           @"xcode.lang.Dylan",
                           @"xcode.lang.Fortran",
                           @"xcode.lang.GLSL",
                           @"xcode.lang.HTML",
                           @"xcode.lang.IntelAsm",
                           @"xcode.lang.Interfacer",
                           @"xcode.lang.Jam",
                           @"xcode.lang.Java",
                           @"xcode.lang.JavaScript",
                           @"xcode.lang.llvm",
                           @"xcode.lang.Lua",
                           @"xcode.lang.Make",
                           @"xcode.lang.man",
                           @"xcode.lang.NQC",
                           @"xcode.lang.ObjectiveC",
                           @"xcode.lang.ObjectiveCPP",
                           @"xcode.lang.OpenCL",
                           @"xcode.lang.Pascal",
                           @"xcode.lang.Perl",
                           @"xcode.lang.PHP",
                           @"xcode.lang.plist",
                           @"xcode.lang.PPCAsm",
                           @"xcode.lang.Python",
                           @"xcode.lang.Rez",
                           @"xcode.lang.Ruby",
                           @"xcode.lang.sh",
                           @"xcode.lang.Veritas",
                           @"xcode.lang.xcconfig",
                           @"xcode.lang.xclangspec",
                           @"xcode.lang.xcsynspec",
                           @"xcode.lang.xctxtmacro",
                           @"xcode.lang.XML",

                           ] retain];
    }
}

+ (NSString *)_identifierForUniqueId: (NSInteger)uid
{
    if (uid < [s_XCLanguageIDs count])
    {
        return [s_XCLanguageIDs objectAtIndex: uid];
    }
    
    return nil;
}

+ (NSInteger)_uniqIdForIdentifier: (NSString *)langID
{
    return [s_XCLanguageIDs indexOfObject: langID];
}

+ (id)specificationRegistryName
{
    
}

+ (id)specificationTypePathExtensions
{
    
}

+ (id)localizedSpecificationTypeName
{
    
}

+ (id)specificationType
{
    
}

+ (Class)specificationTypeBaseClass
{
    return self;
}

- (NSSet *)availableKeywords
{
    
}
- (NSSet *)lexerKeywords
{
    
}
- (NSSet *)syntaxRules
{
    
}
- (XCSourceScanner *)scanner
{
    
}
- (BOOL)includeInMenu
{
    
}
- (NSInteger)uniqueId
{
    
}
- (NSString *)name
{
    
}
- (void)dealloc
{
    
}
- (id)initWithPropertyListDictionary: (NSDictionary *)dict
                            inDomain: (NSString *)domain
{
    
}
@end