//
//  PBXFileType.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "PBXFileType.h"

@implementation PBXFileType

+ (id)fileTypeForPath: (NSString *)path
{
    
}

+ (id)fileTypeUsingFileAttributesAtPath: (NSString *)path
{
    
}

+ (id)fileTypeForPath: (NSString *)path
getExtraFileProperties: (id *)properties
{
    
}

+ (id)guessFileTypeForGenericFileAtPath: (NSString *)path
                     withFileAttributes: (NSDictionary *)attrs
                 getExtraFileProperties: (id *)properties
{
    
}

+ (id)fileTypeForFilenamePattern: (id)pattern
                        isFolder: (BOOL)flag
{
    
}

+ (id)fileTypeMatchingPatternsForFileName: (NSString *)fileName
{
    
}
+ (id)fileTypeForFileName: (NSString *)fileName
{
    
}
+ (id)fileTypeForFileName: (NSString *)fileName
         posixPermissions: (NSUInteger)arg2
              hfsTypeCode: (unsigned int)arg3
           hfsCreatorCode: (unsigned int)arg4
{
    
}

+ (id)bestFileTypeForRepresentingFileAtPath: (NSString *)path
                         withFileAttributes: (NSDictionary *)attrs
                   withLessSpecificFileType: (id)type
                     getExtraFileProperties: (id *)properties
{
    
}

+ (id)wrapperFolderType
{
    
}
+ (id)genericFolderType
{
    
}
+ (id)textFileType
{
    
}
+ (id)genericFileType
{
    
}
+ (id)_fileTypeDetectorArray
{
    
}
+ (id)_fileNamePatternToFileTypeDictionary
{
    
}
+ (id)_magicWordToFileTypeDictionary
{
    
}
+ (id)_lowercasedExtensionToFileTypeDictionary
{
    
}
+ (id)_extensionToFileTypeDictionary
{
    
}
+ (void)registerSpecificationOrProxy:(id)arg1
{
    
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
    
}
- (id)description
{
    
}
- (id)_objectForKeyIgnoringInheritance:(id)arg1
{
    
}
- (id)fileTypePartForIdentifier:(id)arg1
{
    
}

- (id)subpathForWrapperPart:(int)arg1 ofPath:(id)arg2 withExtraFileProperties:(id)arg3
{
}
- (id)extraPropertyNames
{
    
}
- (BOOL)requiresHardTabs
{
    
}
- (BOOL)isScannedForIncludes
{
    
}
- (id)plistStructureDefinitionIdentifier
{
    
}
- (id)xcLanguageSpecificationIdentifier
{
    
}
- (id)languageSpecificationIdentifier
{
    
}

- (BOOL)canSetIncludeInIndex
{
    
}

- (BOOL)isTransparent
{
    
}
- (BOOL)includeInIndex
{
    
}
- (BOOL)isWrapperFolder
{
    
}
- (BOOL)isNonWrapperFolder
{
    
}
- (BOOL)isFolder
{
    
}
- (BOOL)isDocumentation
{
    
}
- (BOOL)isSourceCode
{
    
}
- (BOOL)isPreprocessed
{
    
}
- (BOOL)isTextFile
{
    
}
- (BOOL)isPlainFile
{
    
}
- (BOOL)isExecutableWithGUI
{
    
}
- (BOOL)isExecutable
{
    
}
- (BOOL)isTargetWrapper
{
    
}
- (BOOL)isProjectWrapper
{
    
}
- (BOOL)isStaticFramework
{
    
}
- (BOOL)isFramework
{
    
}
- (BOOL)isStaticLibrary
{
    
}
- (BOOL)isDynamicLibrary
{
    
}
- (BOOL)isLibrary
{
    
}
- (BOOL)isApplication
{
    
}
- (BOOL)isBundle
{
    
}
- (id)hfsTypeCodes
{
    
}
- (id)extensions
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