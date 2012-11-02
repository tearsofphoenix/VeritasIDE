//
//  VXProject.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import "VXDictObject.h"

@interface VXProject : VXDictObject

@property (nonatomic, strong) NSString *mainGroup;

@property (nonatomic, strong) NSString *projectDirPath;

@property (nonatomic, strong) NSString *projectRoot;

@property (nonatomic, strong) NSMutableArray *targets;

@end
