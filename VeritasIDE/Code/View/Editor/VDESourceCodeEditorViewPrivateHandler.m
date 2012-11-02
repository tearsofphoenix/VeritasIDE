//
//  VDESourceCodeEditorViewPrivateHandler.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-28.
//
//

#import "VDESourceCodeEditorViewPrivateHandler.h"
#import "VDESourceCodeEditorView.h"
#import "VDENotificationService.h"
#import "VDEProjectNavigatorView.h"
#import "VXFileReference.h"

@interface VDESourceCodeEditorViewPrivateHandler ()
{
@private
    VDESourceCodeEditorView *_editorView;
}
@end

@implementation VDESourceCodeEditorViewPrivateHandler

- (id)initWithEditorView: (VDESourceCodeEditorView *)editorView
{
    if ((self = [super init]))
    {
        _editorView = editorView;
    }
    
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

@end
