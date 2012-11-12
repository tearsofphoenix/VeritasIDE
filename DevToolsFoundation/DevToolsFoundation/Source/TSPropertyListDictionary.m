//
//  TSPropertyListDictionary.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "TSPropertyListDictionary.h"

@implementation TSPropertyListDictionary

+ (id)propertyListDictionaryWithContentsOfFile: (NSString *)filePath
                                      encoding: (NSStringEncoding)encoding
{
    return [[[self alloc] initWithContentsOfFile: filePath
                                        encoding: encoding] autorelease];
}

+ (id)propertyListDictionaryWithContentsOfString: (NSString *)string
{
    return [[[self alloc] initWithContentsOfString: string] autorelease];
}

+ (id)propertyListDictionaryWithDictionary: (NSDictionary *)dict
{
    return [[[self alloc] initWithDictionary: dict] autorelease];
}

- (id)arrayOrObjectOrNilForKey: (id)key
{
    return [_dict objectForKey: key];
}

- (id)arrayOrNilForKey:(id)key
{
    return [_dict objectForKey: key];
}

- (id)arrayForKey:(id)key
{
    return [_dict objectForKey: key];
}

- (id)dictionaryOrNilForKey: (id)key
{
    return [_dict objectForKey: key];
}
- (id)dictionaryForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)dataOrNilForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)dataForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)stringOrNilForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)stringForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)objectOrNilForKey:(id)key
{
    return [_dict objectForKey: key];
}
- (id)objectForKey:(id)key
{
    return [_dict objectForKey: key];
}

- (id)keyEnumerator
{
    return [_dict keyEnumerator];
}

- (NSUInteger)count
{
    return [_dict count];
}

@synthesize localizationDictionary = _localizationDict;

@synthesize bundle = _bundle;

@synthesize localizedMessageDescription = _localizedMessageDescription;

- (void)dealloc
{
    [_dict release];
    [_localizationDict release];
    [_bundle release];
    [_localizedMessageDescription release];
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (id)initWithContentsOfFile: (NSString *)filePath
                    encoding: (NSStringEncoding)encoding
{
    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfFile: filePath
                                                        encoding: encoding
                                                           error: &error];
    if (error)
    {
        NSLog(@"in func: %s error: %@", __func__, error);
        
        [content release];
        
        return nil;

    }else
    {
        id value = [self initWithContentsOfString: content];
        [content release];
        
        return value;
    }
}

- (id)initWithContentsOfString: (NSString *)content
{
    NSData *data = [content dataUsingEncoding: NSUTF8StringEncoding];
    NSString *error = nil;
    
    id dict  = [NSPropertyListSerialization propertyListFromData: data
                                                mutabilityOption: NSPropertyListMutableContainers
                                                          format: NULL
                                                errorDescription: &error];
    if (error)
    {
        NSLog(@"in func: %s error: %@", __func__, error);
        return nil;
    }else
    {
        if ((self = [super init]))
        {
            _dict = [[NSDictionary alloc] initWithDictionary: dict];
        }
        
        return self;
    }
}

- (id)initWithDictionary: (NSDictionary *)dict
{
    if ((self = [super init]))
    {
        _dict = [[NSDictionary alloc] initWithDictionary: dict];
    }
    
    return self;
}

- (id)_localizedTypeNameForClass:(Class)arg1
{
    
}

@end
