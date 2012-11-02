/*
     File: VDEMainWindowController.h 
 Abstract: Interface for VDEMainWindowController class, the main controller class for this sample.

 */

#import <Cocoa/Cocoa.h>

@class DMTabBar;
@class GCJumpBar;
@class VDEProjectNavigatorView;

@interface VDEMainWindowController : NSWindowController
{
    NSView *_contentView;
    IBOutlet DMTabBar *_navigatorTabBar;
    IBOutlet NSTabView *_navigatorTabView;
    
    IBOutlet VDEProjectNavigatorView *_navigatorView;
    IBOutlet GCJumpBar *_filePathJumpBar;
    
    NSMutableDictionary *_textScrollViews;
    
}


@property (assign) IBOutlet NSView *contentView;

- (void)saveAllUnsavedDocuments;

- (void)tryToStopCurrentRunningSession;

- (void)reloadProjectConfiguration;

#pragma mark - menu actions

- (void)saveCurrentDocument;

- (void)saveCurrentDocumentAsOtherFileType;

- (void)undoInCurrentResponder;

- (void)createNewProject;

@end
