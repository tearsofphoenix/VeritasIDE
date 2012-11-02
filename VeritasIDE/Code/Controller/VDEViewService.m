//
//  VDEViewService.m
//  VeritasIDE
//
//  Created by LeixSnake on 10/26/12.
//
//

#import "VDEViewService.h"
#import "VDEMainWindowController.h"

@interface VDEViewService ()
{
@private
    VDEMainWindowController *_mainWindowController;
}
@end

@implementation VDEViewService

+ (id)identity
{
    return VDEViewServiceID;
}

+ (void)load
{
    [super registerService: self];
}

- (void)initProcessors
{
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              _mainWindowController = [arguments objectAtIndex: 0];
                          })
              forAction: VDEViewServiceRegisterMainWindowControllerAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              NSOpenPanel *openPanel = [NSOpenPanel openPanel];
                              
                              [openPanel setAllowsMultipleSelection: YES];
                              [openPanel setCanChooseDirectories: YES];
                              
                              [openPanel beginWithCompletionHandler:(^(NSInteger result)
                                                                     {
                                                                         if (result == NSFileHandlingPanelOKButton
                                                                             && callback)
                                                                         {
                                                                             callback( @[ [openPanel URLs] ]);
                                                                         }
                                                                     })];
                          })
              forAction: VDEViewServiceOpenFileAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              
                          })
              forAction: VDEViewServiceLoadFilesToCurrentGroupAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              [_mainWindowController saveCurrentDocument];
                          })
              forAction: VDEViewServiceSaveCurrentDocumentAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              [_mainWindowController saveCurrentDocumentAsOtherFileType];
                          })
              forAction: VDEViewServiceSaveAsCurrentDocumentAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              [_mainWindowController close];
                          })
              forAction: VDEViewServiceCloseWindowAction];
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              [_mainWindowController undoInCurrentResponder];
                          })
              forAction: VDEViewServiceUndoCurrentResponderAction];
    
    [self registerBlock: (^(VCallbackBlock callback, NSArray *arguments)
                          {
                              [_mainWindowController createNewProject];
                          })
              forAction: VDEViewServiceCreateNewProjectAction];
}

@end

NSString * const VDEViewServiceID = @"com.veritas.ide.service.view";

NSString * const VDEViewServiceRegisterMainWindowControllerAction = @"action.registerMainWindowController";

NSString * const VDEViewServiceOpenFileAction = @"action.openFile";

NSString * const VDEViewServiceLoadFilesToCurrentGroupAction = @"action.loadFilesToCurrentGroup";

NSString * const VDEViewServiceSaveCurrentDocumentAction = @"action.saveCurrentDocument";

NSString * const VDEViewServiceSaveAsCurrentDocumentAction = @"action.saveCurrentDocumentAs";

NSString * const VDEViewServiceCloseWindowAction = @"action.closeWindow";

NSString * const VDEViewServiceUndoCurrentResponderAction = @"action.undo";

NSString * const VDEViewServiceCreateNewProjectAction = @"action.createNewProject";

