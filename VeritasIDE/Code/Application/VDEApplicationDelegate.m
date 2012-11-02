

#import "VDEApplicationDelegate.h"
#import "VDEMainWindowController.h"
#import "VDEViewService.h"
#import "VDEDataService.h"

@interface VDEApplicationDelegate ()
{
    VDEMainWindowController *_mainWindowController;
}

- (IBAction)openHelp: (id)sender;

@end


@implementation VDEApplicationDelegate

- (void)dealloc
{
    [_mainWindowController release];
    
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication*)application
{
	return NO;
}

- (void)applicationDidFinishLaunching: (NSNotification*)notification
{
	_mainWindowController = [[VDEMainWindowController alloc] initWithWindowNibName: @"MainWindow"];
    
    VSC(VDEViewServiceID, VDEViewServiceRegisterMainWindowControllerAction, nil, @[ _mainWindowController ]);
    
	[_mainWindowController showWindow: self];
}

#pragma mark - Menu actions

- (IBAction)openHelp: (id)sender
{
	NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"Test"
                                                         ofType: @"v"];
	[[NSWorkspace sharedWorkspace] openFile: fullPath];
}

- (IBAction)openDocument: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceOpenFileAction,
        (^(NSArray *arguments)
         {
             NSArray *fileURLs = [arguments objectAtIndex: 0];
             
             if ([fileURLs count] == 1)
             {
                 //is this a project file?
                 //
                 NSURL *fileURL = [fileURLs objectAtIndex: 0];
                 
                 if ([[fileURL absoluteString] hasSuffix: @".veritasproject"])
                 {
                     //deal as project file
                     VSC(VDEDataServiceID, VDEDataServiceLoadProjectFileAction, nil, @[ [fileURL path] ]);
                     
                 }else
                 {
                     //not a project file, try to open as normal file
                     //
                     VSC(VDEViewServiceID, VDEViewServiceLoadFilesToCurrentGroupAction, nil, arguments);
                 }
             }else
             {
                 VSC(VDEViewServiceID, VDEViewServiceLoadFilesToCurrentGroupAction, nil, arguments);
             }
             
         }), nil);
}

- (IBAction)savecurrentDocument: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceSaveCurrentDocumentAction, nil, nil);
}

- (IBAction)saveCurrentDocumentAsOtherFileType: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceSaveAsCurrentDocumentAction, nil, nil);
}

#pragma mark - VeritasIDE actions

- (IBAction)showPreferencesPanel: (id)sender
{
    
}

#pragma mark - New actions

- (IBAction)createNewFile: (id)sender
{
    
}

- (IBAction)createNewProject: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceCreateNewProjectAction, nil, nil);
}

- (IBAction)createNewWorkspace: (id)sender
{
    
}

#pragma mark - file actions

- (IBAction)performCloseWindowAction: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceCloseWindowAction, nil, nil);
}

- (IBAction)performUndoAction: (id)sender
{
    VSC(VDEViewServiceID, VDEViewServiceUndoCurrentResponderAction, nil, nil);
}

@end
