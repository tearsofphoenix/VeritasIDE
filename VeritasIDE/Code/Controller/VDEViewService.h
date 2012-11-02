//
//  VDEViewService.h
//  VeritasIDE
//
//  Created by LeixSnake on 10/26/12.
//
//

#import <VeritasMachineKit/VeritasMachineKit.h>

@interface VDEViewService : VMetaService

@end

extern NSString * const VDEViewServiceID;

extern NSString * const VDEViewServiceRegisterMainWindowControllerAction;

extern NSString * const VDEViewServiceOpenFileAction;

extern NSString * const VDEViewServiceLoadFilesToCurrentGroupAction;

extern NSString * const VDEViewServiceSaveCurrentDocumentAction;

extern NSString * const VDEViewServiceSaveAsCurrentDocumentAction;

extern NSString * const VDEViewServiceCloseWindowAction;

extern NSString * const VDEViewServiceUndoCurrentResponderAction;

extern NSString * const VDEViewServiceCreateNewProjectAction;