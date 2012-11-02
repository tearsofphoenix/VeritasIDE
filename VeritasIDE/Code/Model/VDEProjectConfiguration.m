//
//  VDEProjectConfiguration.m
//  VeritasIDE
//
//  Created by LeixSnake on 10/25/12.
//
//

#import "VDEProjectConfiguration.h"
#import "VXProject.h"
#import "VXGroup.h"
#import "VXFileReference.h"


@interface VDEProjectConfiguration ()
{
@private
    
    NSString *_projectFilePath;
    NSString *_projectFolderPath;
    
    NSMutableDictionary *_contents;
    NSMutableDictionary *_projectObjects;
    
    VXProject *_project;
    NSString *_rootObjectID;
    
    VXGroup *_mainGroup;
}
@end

@implementation VDEProjectConfiguration

@synthesize projectFileEncodingName = _projectFileEncodingName;

- (id)initWithFilePath: (NSString *)filePath
{
    if ((self = [super init]))
    {
        _projectFilePath = [filePath retain];
        _projectFolderPath = [[_projectFilePath stringByDeletingLastPathComponent] retain];
        
        _contents = [[NSMutableDictionary alloc] init];
        
        NSString *path = _projectFilePath;
        
        NSError *error = nil;
        
        NSDictionary * contents = [NSJSONSerialization JSONObjectWithData: [[[NSData alloc] initWithContentsOfFile: path] autorelease]
                                                                  options: 0
                                                                    error: &error];
        if (error)
        {
            NSLog(@"%@", error);
        }else
        {
            [_contents setDictionary: contents];
            _projectObjects = [[NSMutableDictionary alloc] initWithCapacity: [_contents count]];
            
            [self _parseProjectDictionary];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_projectFilePath release];
    [_projectFolderPath release];
    [_projectObjects release];
    
    [super dealloc];
}

static NSArray *VDEProjectConfigurationChildrenOfObject(VDEProjectConfiguration *self, VXDictObject *obj)
{
    VXDictObject *value = [self->_projectObjects objectForKey: [obj identity]];
    
    if ([value isKindOfClass: [VXGroup class]])
    {
        NSArray *childrenIDs = [value valueForKey: @"children"];
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSString *idLooper in childrenIDs)
        {
            [array addObject: [self->_projectObjects objectForKey: idLooper]];
        }
        
        return array;
        
    }else
    {
        return nil;
    }
}

static void VDEProjectConfigratuonTagObjects(VDEProjectConfiguration *self, id group)
{
    NSArray *children = VDEProjectConfigurationChildrenOfObject(self, group);
    [group setChildren: children];
    
    if (![group absolutePath])
    {
        [group setAbsolutePath: [self projectFolderPath]];
    }
    
    [children enumerateObjectsWithOptions: NSEnumerationConcurrent
                               usingBlock: (^(VXDictObject *childLooper, NSUInteger idx, BOOL *stop)
                                            {
                                                [childLooper setParentObject: group];
                                                [childLooper setIndexInParent: idx];
                                                
                                                if ([childLooper isKindOfClass: [VXGroup class]])
                                                {
                                                    VDEProjectConfigratuonTagObjects(self, childLooper);
                                                    
                                                }else if([childLooper isKindOfClass: [VXFileReference class]])
                                                {
                                                    if ([(VXFileReference *)childLooper isFolder])
                                                    {
                                                        [childLooper setAbsolutePath: [[group absolutePath] stringByAppendingPathComponent: [childLooper valueForKey: @"path"]] ];

                                                        VDEProjectConfigratuonTagObjects(self, childLooper);
                                                    }else
                                                    {
                                                        [childLooper setAbsolutePath: [[self projectFolderPath] stringByAppendingPathComponent: [childLooper valueForKey: @"path"]] ];
                                                    }
                                                }
                                                
                                            })];
}

- (void)_parseProjectDictionary
{
    NSDictionary *objects = [_contents objectForKey: @"objects"];
    
    [objects enumerateKeysAndObjectsUsingBlock: (^(NSString *objIdentity, NSDictionary *objectConfigurationLooper, BOOL *stop)
                                                 {
                                                     NSString *classNmae = [objectConfigurationLooper objectForKey: @"isa"];
                                                     Class objClass = NSClassFromString(classNmae);
                                                     
                                                     NSMutableDictionary *objConfiguration = [[NSMutableDictionary alloc] initWithDictionary: objectConfigurationLooper];
                                                     [objConfiguration removeObjectForKey: @"isa"];
                                                     
                                                     id instance = [[objClass alloc] initWithDictionary: objConfiguration];
                                                     
                                                     [objConfiguration release];
                                                     
                                                     [instance setIdentity: objIdentity];
                                                     
                                                     [_projectObjects setObject: instance
                                                                         forKey: objIdentity];
                                                     [instance release];
                                                 })];
    
    _rootObjectID = [[_contents objectForKey: @"rootObject"] retain];
    _project = [_projectObjects objectForKey: _rootObjectID];
    
    VXGroup *mainGroup = [self mainGroup];
    VDEProjectConfigratuonTagObjects(self, mainGroup);    
}

- (NSString *)projectFolderPath
{
    return _projectFolderPath;
}

- (VXGroup *)mainGroup
{
    if (!_mainGroup)
    {
        NSString *mainGroupID = [_project mainGroup];
        _mainGroup = [_projectObjects objectForKey: mainGroupID];
    }
    
    return _mainGroup;
}

- (id)objectWithID: (NSString *)identity
{
    return [_projectObjects objectForKey: identity];
}

- (VXProject *)project
{
    return _project;
}

//usually a VXProject object
//
- (NSString *)rootObjectID
{
    return _rootObjectID;
}

- (id)objectAtIndexPath: (NSIndexPath *)indexPath
{
    for (VXDictObject *obj in [_projectObjects allValues])
    {
        if ([indexPath isEqual: [obj indexPath]])
        {
            return obj;
        }
    }
    
    return nil;
}

@synthesize workingPath = _workingPath;

- (NSArray *)objects
{
    return [_projectObjects allValues];
}

@end
