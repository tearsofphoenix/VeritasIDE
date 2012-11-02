//
//  VDEProjectConfiguration.h
//  VeritasIDE
//
//  Created by LeixSnake on 10/25/12.
//
//

#import <Foundation/Foundation.h>

@class VXDictObject;
@class VXGroup;
@class VXProject;

@interface VDEProjectConfiguration : NSObject

@property (nonatomic, strong) NSString *projectFileEncodingName;

@property (nonatomic) NSInteger objectVersion;

@property (nonatomic, strong) NSString *workingPath;

- (id)initWithFilePath: (NSString *)filePath;

- (NSString *)projectFolderPath;

- (VXGroup *)mainGroup;

- (id)objectWithID: (NSString *)identity;

- (id)objectAtIndexPath: (NSIndexPath *)indexPath;

- (NSString *)rootObjectID;

//usually a VXProject object
//
- (VXProject *)project;

- (NSArray *)objects;

@end
