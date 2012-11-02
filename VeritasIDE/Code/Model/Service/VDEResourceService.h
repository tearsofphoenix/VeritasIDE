//
//  VDEResourceService.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-27.
//
//

#import <VeritasMachineKit/VeritasMachineKit.h>
#import <Cocoa/Cocoa.h>

@interface VDEResourceService : VMetaService

+ (NSImage *)imageForFileType: (NSString *)fileType;

+ (NSString *)applicationSupportPath;

@end

extern NSString * const VDEResourceServiceID;

extern NSString * const VDEResourceFolderIcon;

extern NSString * const VDEResourceServiceApplicationSupportPath;

//extern NSString * const VDEResourceServiceCreateFolderAction;
//
//extern NSString * const VDEResourceServiceCopyFileAction;
//
//extern NSString * const VDEResourceServiceMoveFileAction;

