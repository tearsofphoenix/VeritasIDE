//
//  XCColorTheme.m
//  XCodeEdit
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "XCColorTheme.h"

@implementation XCColorTheme

static NSMutableDictionary *s_XCColorBuiltInThemes = nil;

+ (NSMutableDictionary *)builtInThemes
{
    if (!s_XCColorBuiltInThemes)
    {
        s_XCColorBuiltInThemes = [[NSMutableDictionary alloc] init];
    }
    
    return s_XCColorBuiltInThemes;
}

static NSMutableDictionary *s_XCColorUserThemes = nil;

+ (NSMutableDictionary *)userThemes
{
    if (!s_XCColorUserThemes)
    {
        s_XCColorUserThemes = [[NSMutableDictionary alloc] init];
    }
    
    return s_XCColorUserThemes;
}

static NSString *s_XCColorThemePath = nil;

+ (void)setThemePath: (NSString *)path
{
    if (s_XCColorThemePath != path)
    {
        [s_XCColorThemePath release];
        s_XCColorThemePath = [path retain];
        
        [self _addThemesFromDirectory: path
                         toDictionary: [self userThemes]];
    }
}

+ (id)themeWithName: (NSString *)name
{
    id theme = [[self builtInThemes] objectForKey: name];
    if (theme)
    {
        return theme;
    }
    
    theme = [[self userThemes] objectForKey: name];
    
    return theme;
}

static XCColorTheme *s_XCColorThemeCurrent = nil;

+ (void)setCurrentTheme: (id)theme
{
    if (s_XCColorThemeCurrent != theme)
    {
        [s_XCColorThemeCurrent release];
        s_XCColorThemeCurrent = [theme retain];
        
        [[self userThemes] setObject: s_XCColorThemeCurrent
                              forKey: [theme name]];
    }
}

+ (id)currentTheme
{
    return s_XCColorThemeCurrent;
}

+ (void)_addThemesFromDirectory: (NSString *)from
                   toDictionary: (NSMutableDictionary *)to
{
    if (from && to)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *contents = [fileManager contentsOfDirectoryAtPath: from
                                                             error: &error];
        if (error)
        {
            NSLog(@"in func: %s error: %@", __func__, error);
        }else
        {
            for (NSString *fileName in contents)
            {
                if ([fileName hasSuffix: @".xccolortheme"])
                {
                    [self _addThemesFromPathList: [from stringByAppendingPathComponent: fileName]
                                    toDictionary: to];
                }
            }
        }
    }
}

+ (void)_addThemesFromPathList: (NSString *)path
                  toDictionary: (NSMutableDictionary *)to
{
    NSDictionary *dictLooper = [NSDictionary dictionaryWithContentsOfFile: path];
    
    [to enumerateKeysAndObjectsUsingBlock: (^(NSString *key, NSMutableDictionary *obj, BOOL *stop)
                                            {
                                                [obj setDictionary: [dictLooper objectForKey: key]];
                                            })];
}

+ (id)systemTheme
{
    return nil;
}

- (void)activate
{
    [XCColorTheme setCurrentTheme: self];
}

- (NSDictionary *)fonts
{
    return [_dict objectForKey: @"Fonts"];
}

- (NSDictionary *)colors
{
    return [_dict objectForKey: @"Colors"];
}

@synthesize name = _name;

- (BOOL)isBuiltInTheme
{
    return [[XCColorTheme builtInThemes] objectForKey: _name] == self;
}

- (void)save
{
    [self saveToPath: [self path]];
}

- (NSString *)path
{
    return [s_XCColorThemePath stringByAppendingPathComponent: _name];
}

- (void)saveToPath: (NSString *)path;
{
    [_dict writeToFile: path
            atomically: YES];
}

- (void)copyFromTheme: (XCColorTheme *)theme
{
    if (self != theme)
    {
        [_dict setDictionary: theme->_dict];
        [self setName: theme->_name];
    }
}

- (void)dealloc
{
    [_name release];
    [_dict release];
    
    [super dealloc];
}

static void f_XCColorInitDictionary(NSMutableDictionary **_dict)
{
    *_dict = [[NSMutableDictionary alloc] initWithCapacity: 2];

    NSMutableDictionary *selfColors = [[NSMutableDictionary alloc] init];
    
    [*_dict setObject: selfColors
              forKey: @"Colors"];
    
    [selfColors release];
    
    NSMutableDictionary *selfFonts = [[NSMutableDictionary alloc] init];
    [*_dict setObject: selfFonts
              forKey: @"Fonts"];
    [selfFonts release];

}

- (id)initWithPath: (NSString *)path
{
    if ((self = [super init]))
    {
        f_XCColorInitDictionary(&_dict);
        
        NSString *fileName = [path lastPathComponent];

        if (fileName && [fileName hasSuffix: @".xccolortheme"])
        {
            [self setName: [fileName stringByDeletingPathExtension]];
            
            [XCColorTheme _addThemesFromPathList: path
                                    toDictionary: _dict];
        }
    }
    
    return self;
}

- (id)initWithColors: (NSDictionary *)colors
               fonts: (NSDictionary *)fonts
{
    if ((self = [super init]))
    {
        f_XCColorInitDictionary(&_dict);

        [[_dict objectForKey: @"Colors"] setDictionary: colors];
        
        [[_dict objectForKey: @"Fonts"] setDictionary: fonts];
    }
    
    return self;
}

- (id)init
{
    return [self initWithPath: nil];
}

@end