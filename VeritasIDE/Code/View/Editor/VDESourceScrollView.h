//
//  VDESourceScrollView.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-28.
//
//

#import <Cocoa/Cocoa.h>

@class VDESourceCodeEditorView;

@interface VDESourceScrollView : NSScrollView
{
    VDESourceCodeEditorView *_editorView;
}

- (VDESourceCodeEditorView *)editorView;

@end
