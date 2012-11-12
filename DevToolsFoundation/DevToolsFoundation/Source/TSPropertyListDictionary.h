//
//  TSPropertyListDictionary.h
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSPropertyListDictionary : NSDictionary
{
    NSDictionary *_dict;
    
    NSString *_localizedDesc;
    NSBundle *_bundle;
    NSDictionary *_localizationDict;
}

+ (id)propertyListDictionaryWithContentsOfFile: (NSString *)filePath
                                      encoding: (NSStringEncoding)encoding;

+ (id)propertyListDictionaryWithContentsOfString: (NSString *)string;

+ (id)propertyListDictionaryWithDictionary: (NSDictionary *)dict;

- (id)arrayOrObjectOrNilForKey: (id)key;
- (id)arrayOrNilForKey:(id)key;
- (id)arrayForKey:(id)key;

- (id)dictionaryOrNilForKey: (id)key;
- (id)dictionaryForKey:(id)key;
- (id)dataOrNilForKey:(id)key;
- (id)dataForKey:(id)key;
- (id)stringOrNilForKey:(id)key;
- (id)stringForKey:(id)key;
- (id)objectOrNilForKey:(id)key;
- (id)objectForKey:(id)key;
- (id)keyEnumerator;
- (NSUInteger)count;

@property (copy) NSDictionary *localizationDictionary;

@property (retain) NSBundle *bundle;

@property (retain) NSString *localizedMessageDescription;

- (void)dealloc;
- (id)init;

- (id)initWithContentsOfFile: (NSString *)filePath
                    encoding: (NSStringEncoding)encoding;

- (id)initWithContentsOfString: (NSString *)content;
- (id)initWithDictionary: (NSDictionary *)dict;

- (id)_localizedTypeNameForClass:(Class)arg1;

@end
