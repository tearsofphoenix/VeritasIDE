//
//  XCSpecification.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCSpecification.h"

@implementation XCSpecification

+ (BOOL)_booleanValueForValue: (id)value
{
    return [value boolValue];
}

+ (void)loadSpecificationsWithProperty: (id)property
{
    
}

+ (Class)specificationBaseClassForType: (NSString *)type
{
    
}

+ (id)specificationTypeForPathExtension: (NSString *)pathExtension
{
    
}

+ (id)allRegisteredSpecifications
{
    
}

+ (id)registeredBaseSpecifications
{
    
}

+ (id)registeredBaseSpecificationsInDomain: (NSString *)domain
{
    
}

+ (id)_subSpecificationsOfSpecification: (XCSpecification *)spec
                               inDomain: (NSString *)domain
{
    
}

+ (id)registeredSpecifications
{
    
}

+ (id)registeredSpecificationsInDomain: (NSString *)domain
{
    
}

+ (id)registeredSpecificationsInDomainOrDefault: (NSString *)domain
{
    
}

+ (id)specificationsForIdentifiers: (NSArray *)identifiers
{
    
}

+ (id)specificationsForIdentifiers: (NSArray *)identifiers
                          inDomain: (NSString *)domain
{
    
}

+ (id)specificationForIdentifier: (NSString *)identifier
{
    
}

+ (id)specificationForIdentifier: (NSString *)identifier
                        inDomain: (NSString *)domain
{
    
}

+ (void)_getDomain: (NSString **)outDomain
        identifier: (NSString **)outIdentifier
fromDomainPrefixedIdentifier: (NSString *)domainPrefix
{
    
}

+ (id)registerSpecificationProxiesFromPropertyListsInDirectory: (id)arg1
                                                   recursively: (BOOL)flag
{
    
}

+ (id)registerSpecificationProxiesFromPropertyListsInDirectory: (id)arg1
                                                   recursively: (BOOL)arg2
                                                      inDomain: (NSString *)domain
{
    
}

+ (id)registerSpecificationProxiesFromPropertyListsInDirectory: (id)arg1
                                                   recursively: (BOOL)flag
                                                      inDomain: (NSString *)domain
                                                      inBundle: (NSBundle *)bundle
{
    
}

+ (BOOL)_shouldRecurseIntoDirectoryNamed: (NSString *)directory
                                  ofType: (NSString *)type
{
    
}

+ (id)_registerSpecificationProxiesOfType: (NSString *)type
                    fromDictionaryOrArray: (id)value
                              inDirectory: (NSString *)directory
                                   bundle: (NSBundle *)bundle
                        sourceDescription: (NSString *)des
                                 inDomain: (NSString *)domain
{
    
}

+ (id)registerSpecificationProxyFromPropertyList: (id)arg1
{
    
}

+ (id)registerSpecificationProxyFromPropertyList: (id)arg1
                                        inDomain: (NSString *)domain
{
    
}

+ (void)registerSpecificationOrProxy:(id)arg1
{
    
}

+ (void)registerSpecificationTypeBaseClass:(Class)arg1
{
    
}

+ (id)_pathExensionsToTypesRegistry
{
    
}

+ (id)_typesToSpecTypeBaseClassesRegistry
{
    
}

+ (id)specificationRegistryForDomain:(id)arg1
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
    return [self specificationType];
}

+ (id)specificationType
{
    return @"Generic";
}

+ (Class)specificationTypeBaseClass
{
    return self;
}

- (NSString *)description
{
    return [self localizedDescription];
}

- (id)valueForUndefinedKey:(id)arg1
{
    
}

- (id)arrayOrStringForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}

- (BOOL)boolForKeyFromProxy:(id)arg1
{
    
}

- (BOOL)boolForKey:(id)arg1
{
    return [[_properties objectForKey: arg1] boolValue];
}

- (double)doubleForKey:(id)arg1
{
    return [[_properties objectForKey: arg1] doubleValue];
}
- (float)floatForKey:(id)arg1
{
    return [[_properties objectForKey: arg1] floatValue];
}
- (long long)longLongForKey:(id)arg1
{
    return [[_properties objectForKey: arg1] longLongValue];
}
- (NSInteger)integerForKey:(id)arg1
{
    return [[_properties objectForKey: arg1] integerValue];
}

- (id)dataForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}
- (id)dictionaryForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}
- (id)arrayForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}
- (id)stringForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}
- (id)objectForKey:(id)arg1
{
    return [_properties objectForKey: arg1];
}

- (id)_objectForKeyIgnoringInheritance:(id)arg1
{
    
}

- (NSComparisonResult)nameCompare:(id)arg1
{
    return [[self name] compare: [arg1 name]];
}
- (NSComparisonResult)identifierCompare:(id)arg1
{
    return [[self identifier] compare: [arg1 identifier]];
}

- (NSString *)localizedDescription
{
    return [NSString stringWithFormat: @"%@ ID: %@ name: %@ domain: %@",
            [self class], [self identifier], [self name], [self domain]];
}

- (NSString *)name
{
    return [_properties objectForKey: @"Name"];
}

- (NSString *)domain
{
    return _domain;
}

- (NSBundle *)bundle
{
    return _bundle;
}
- (NSDictionary *)localizationDictionary
{
    return _localizationDictionary;
}

- (NSDictionary *)properties
{
    return _properties;
}
- (NSString *)type
{
    return [_properties objectForKey: @"Type"];
}

- (NSString *)identifier
{
    return _identifier;
}

- (BOOL)isMissingSpecificationProxy
{
    
}

- (id)loadedSpecification
{
    
}

- (BOOL)isNotYetLoadedSpecificationProxy
{
    
}

- (BOOL)isAbstract
{
    return _superSpecification == nil;
}

- (BOOL)isKindOfSpecification: (id)arg1
{
    
}

- (id)subSpecifications
{
    
}

- (id)subSpecificationsInDomain: (NSString *)domain
{
    
}

- (id)superSpecification
{
    return _superSpecification;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (id)init
{
    return [self initWithPropertyListDictionary: nil
                                       inDomain: nil];
}

- (id)initAsMissingSpecificationProxyWithIdentifier: (NSString *)ID
                                               name: (NSString *)name
                                        description: (NSString *)des
                                           inDomain: (NSString *)domain
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (id)initWithPropertyListDictionary: (NSDictionary *)dict
{
    return [self initWithPropertyListDictionary: dict
                                       inDomain: nil];
}

- (id)initWithPropertyListDictionary: (NSDictionary *)dict
                            inDomain: (NSString *)domain
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

@end
