/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "XCSpecification.h"

@class TSPropertyListDictionary, XCSourceScanner;

@interface XCLanguageSpecification : XCSpecification
{
    NSInteger _uniqueId;
    BOOL _includeInMenu;
    Class _scannerClass;
    XCSourceScanner *_scanner;
    TSPropertyListDictionary *_syntaxRules;
}

+ (id)_identifierForUniqueId:(NSInteger)arg1;
+ (NSInteger)_uniqIdForIdentifier:(id)arg1;
+ (id)specificationRegistryName;
+ (id)specificationTypePathExtensions;
+ (id)localizedSpecificationTypeName;
+ (id)specificationType;
+ (Class)specificationTypeBaseClass;
- (id)availableKeywords;
- (id)lexerKeywords;
- (id)syntaxRules;
- (id)scanner;
- (BOOL)includeInMenu;
- (NSInteger)uniqueId;
- (id)name;
- (void)dealloc;
- (id)initWithPropertyListDictionary:(id)arg1 inDomain:(id)arg2;

@end

