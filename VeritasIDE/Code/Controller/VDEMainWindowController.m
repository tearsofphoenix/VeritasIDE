/*
 File: VDEMainWindowController.m
 Abstract: Interface for VDEMainWindowController class, the main controller class for this sample.
 
 */

#import "VDEMainWindowController.h"

#import "VDESourceCodeEditorView.h"
#import "VDEProjectNavigatorView.h"
#import "DMTabBar.h"
#import "VDEMainWindowControllerPrivateHandler.h"
#import "VXFileReference.h"
#import "VDESourceScrollView.h"
#import "GCJumpBar.h"
#import "NSMenu+VDEProjectConfigurationExtension.h"
#import "VDEProjectConfiguration.h"
#import "VDEServices.h"

#define kMinOutlineViewSplit	120.0f

@interface VDEMainWindowController ()<DMTabBarDelegate, GCJumpBarDelegate>
{
@private
    VDEMainWindowControllerPrivateHandler *_handler;
    NSMenu *_filePathMenu;
    VDEProjectConfiguration *_projectConfiguration;
    VDESourceScrollView *_currentDocumentScrollView;
}
@end

@implementation VDEMainWindowController

static void VDEMainWindowControllerInitializeTabView(VDEMainWindowController *self, NSTabView *_navigatorTabView)
{
    NSTabViewItem *item = [_navigatorTabView tabViewItemAtIndex: 0];
    [item setView: self->_navigatorView];
    
    item = [_navigatorTabView tabViewItemAtIndex: 1];
    
    NSView *emptyView = [[NSView alloc] init];
    [[emptyView layer] setBackgroundColor: [[NSColor redColor] CGColor]];
    [item setView: emptyView];
    [emptyView release];
    
}

@synthesize contentView = _contentView;

- (id)initWithWindow: (NSWindow *)window
{
    if ((self = [super initWithWindow: window]))
    {
        _handler = [[VDEMainWindowControllerPrivateHandler alloc] initWithController: self];
        _textScrollViews = [[NSMutableDictionary alloc] init];
        _filePathMenu = [[NSMenu alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_handler release];
    [_textScrollViews release];
    [_filePathMenu release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
	[[self window] setAutorecalculatesContentBorderThickness: YES
                                                     forEdge: NSMinYEdge];
    
	[[self window] setContentBorderThickness: 30
                                     forEdge: NSMinYEdge];
    
    [[VDENotificationService serviceCenter] addObserver: self
                                               selector: @selector(notificationForDidSelectSingleFile:)
                                                   name: VDEProjectNavigatorViewDidSelectSingleFileNotification
                                                 object: nil];
    //Navigator views
    //
    [_navigatorTabBar setDataSource: _handler];
    [_navigatorTabBar setDelegate: self];
    
    VDEMainWindowControllerInitializeTabView(self, _navigatorTabView);
    
    
    //jump bar
    [_filePathJumpBar setDelegate: self];
    
    
#ifdef DEBUG
    
    NSString *fileURL = [NSHomeDirectory() stringByAppendingPathComponent: @"/VDETest/Outline.veritasproject"];
    
    VSC(VDEDataServiceID, VDEDataServiceLoadProjectFileAction, nil, @[ fileURL ]);
    
#else
    
#endif
}

#pragma mark - notifications

- (void)reloadProjectConfiguration
{
    _projectConfiguration = [_handler currentProjectConfiguration];
    
    [_filePathMenu buildMenuItemWithConfiguration: _projectConfiguration];
    
    [_filePathJumpBar setMenu: _filePathMenu];
    
    [_navigatorView setProjectConfiguration: _projectConfiguration];
}

- (void)_showEditorViewForFile: (VXFileReference *)fileReference
{
    NSString *fileIdentity = [fileReference identity];
    
    VDESourceScrollView *scrollView = [_textScrollViews objectForKey: fileIdentity];
    
    if (!scrollView)
    {
        NSError *error = nil;
        
        NSString *fileContent = [NSString stringWithContentsOfFile: [fileReference absolutePath]
                                                          encoding: NSUTF8StringEncoding
                                                             error: &error];
        if (error)
        {
            VDEExceptionServiceHandleError(error);
        }else
        {
            CGRect frame = [_contentView bounds];
            frame.size.height -= [_filePathJumpBar frame].size.height;
            
            scrollView = [[VDESourceScrollView alloc] initWithFrame: frame];
            [[scrollView editorView] setString: fileContent];
            
            [_textScrollViews setObject: scrollView
                                 forKey: fileIdentity];
            
            [scrollView release];
        }
    }
    
    [_contentView addSubview: scrollView
                  positioned: NSWindowAbove
                  relativeTo: nil];
    
    _currentDocumentScrollView = scrollView;
}

- (void)notificationForDidSelectSingleFile: (NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    VXFileReference *fileReference = [userInfo objectForKey: @"item"];
    
    [_filePathJumpBar setSelectedIndexPath: [fileReference indexPath]];
    
    [self _showEditorViewForFile: fileReference];
}

#pragma mark - GCJumpBarDelegate

- (void)jumpBar: (GCJumpBar *)jumpBar didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
    VXFileReference *fileReference = [_projectConfiguration objectAtIndexPath: indexPath];
    
    if (fileReference)
    {
        [self _showEditorViewForFile: fileReference];
    }
}

#pragma mark - DMTabBarDelegate

- (void)tabBar: (DMTabBar *)tabBar
 didSelectItem: (DMTabBarItem *)item
       atIndex: (NSUInteger)idx
{
    [_navigatorTabView selectTabViewItemAtIndex: idx];
}

#pragma mark - Split View Delegate

//	What you really have to do to set the minimum size of both subviews to kMinOutlineViewSplit points.
//
- (CGFloat)splitView: (NSSplitView *)splitView constrainMinCoordinate: (CGFloat)proposedCoordinate ofSubviewAt: (int)index
{
	return proposedCoordinate + kMinOutlineViewSplit;
}

- (CGFloat)splitView: (NSSplitView *)splitView constrainMaxCoordinate: (CGFloat)proposedCoordinate ofSubviewAt: (int)index
{
	return proposedCoordinate - kMinOutlineViewSplit;
}

//	Keep the left split pane from resizing as the user moves the divider line.
//
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSRect newFrame = [sender frame]; // get the new size of the whole splitView
	NSView *left = [[sender subviews] objectAtIndex:0];
	NSRect leftFrame = [left frame];
	NSView *right = [[sender subviews] objectAtIndex:1];
	NSRect rightFrame = [right frame];
    
	CGFloat dividerThickness = [sender dividerThickness];
    
	leftFrame.size.height = newFrame.size.height;
    
	rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
	rightFrame.size.height = newFrame.size.height;
	rightFrame.origin.x = leftFrame.size.width + dividerThickness;
    
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

#pragma mark - save actions

static void VDEMainWindowControllerSaveDocument(VDESourceScrollView *view, VXFileReference *fileReference)
{
    NSError *error = nil;
    [[[view editorView] string] writeToFile: [fileReference absolutePath]
                                 atomically: YES
                                   encoding: NSUTF8StringEncoding
                                      error: &error];
    if (error)
    {
        VDEExceptionServiceHandleError(error);
    }
}

- (void)saveCurrentDocument
{
    NSString *fileIdentity = [[_textScrollViews allKeysForObject: _currentDocumentScrollView] objectAtIndex: 0];
    VXFileReference *fileReference = [_projectConfiguration objectWithID: fileIdentity];
    
    VDEMainWindowControllerSaveDocument(_currentDocumentScrollView, fileReference);
}

- (void)saveCurrentDocumentAsOtherFileType
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    [savePanel setCanSelectHiddenExtension: YES];
    [savePanel beginSheetModalForWindow: [self window]
                      completionHandler: (^(NSInteger result)
                                          {
                                              if (result == NSFileHandlingPanelOKButton)
                                              {
                                                  NSURL *fileURL = [savePanel URL];
                                                  
                                                  NSError *error = nil;
                                                  [[[_currentDocumentScrollView editorView] string] writeToURL:  fileURL
                                                                                                    atomically: YES
                                                                                                      encoding: NSUTF8StringEncoding
                                                                                                         error: &error];
                                                  if (error)
                                                  {
                                                      VDEExceptionServiceHandleError(error);
                                                  }
                                              }
                                              
                                          })];
}

#pragma mark - toolbar delegate

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar
     itemForItemIdentifier: (NSString *)itemIdentifier
 willBeInsertedIntoToolbar: (BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
    
    VDEToolBarItemView *itemView = [[VDEToolBarItemView alloc] initWithFrame: NSMakeRect(0, 0, 120, 36)];
    [itemView setDelegate: _handler];
    [item setView: itemView];
    
    [itemView release];
    
    return [item autorelease];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar
{
    return (@[@"run"]);
}

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar
{
    return (@[@"run"]);
}

#pragma mark - toolbar actions

- (void)saveAllUnsavedDocuments
{
    [_textScrollViews enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                              usingBlock: (^(NSString *fileIdentity, VDESourceScrollView *view, BOOL *stop)
                                                           {
                                                               //VXFileReference *fileReference = [_projectConfiguration objectWithID: fileIdentity];
                                                               
                                                           })];
}

- (void)tryToStopCurrentRunningSession
{
    
}

#pragma mark - view actions

- (void)close
{
    [super close];
}

- (void)undoInCurrentResponder
{
    [[[[self window] firstResponder] undoManager] undo];
}

+ (void)_createProjectWithTemplateAtURL: (NSURL *)url
{
    NSString *filePath = [url path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if(![fileManager fileExistsAtPath: filePath])
    {
        [fileManager createDirectoryAtPath: filePath
               withIntermediateDirectories: YES
                                attributes: nil
                                     error: &error];
        if (error)
        {
            VDEExceptionServiceHandleError(error);
            return;
        }
    }
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    [fileManager copyItemAtPath: [resourcePath stringByAppendingPathComponent: @"/Outline.veritasproject"]
                         toPath: [filePath stringByAppendingPathComponent: @"/Outline.veritasproject"]
                          error: &error];
    if (error)
    {
        VDEExceptionServiceHandleError(error);
        return;
    }
    
    [fileManager copyItemAtPath: [resourcePath stringByAppendingPathComponent: @"/Test.v"]
                         toPath: [filePath stringByAppendingPathComponent: @"/Test.v"]
                          error: &error];
    if (error)
    {
        VDEExceptionServiceHandleError(error);
        return;
    }

    [fileManager copyItemAtPath: [resourcePath stringByAppendingPathComponent: @"/Main.v"]
                         toPath: [filePath stringByAppendingPathComponent: @"/Main.v"]
                          error: &error];
    if (error)
    {
        VDEExceptionServiceHandleError(error);
        return;
    }
}

- (void)createNewProject
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetModalForWindow: [self window]
                      completionHandler: (^(NSInteger result)
                                          {
                                              if (result == NSFileHandlingPanelOKButton)
                                              {
                                                  NSURL *fileURL = [savePanel URL];
                                                  [[self class] _createProjectWithTemplateAtURL: fileURL];
                                                  
                                                  NSString *path = [[fileURL path] stringByAppendingPathComponent: @"Outline.veritasproject"];
                                                  
                                                  VSC(VDEDataServiceID, VDEDataServiceLoadProjectFileAction, nil, @[ path ]);
                                                  
                                              }else
                                              {
                                                  ///TODO:
                                              }
                                          })];
}

@end
