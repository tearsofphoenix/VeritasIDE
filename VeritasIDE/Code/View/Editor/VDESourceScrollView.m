//
//  VDESourceScrollView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-28.
//
//

#import "VDESourceScrollView.h"
#import "NoodleLineNumberView.h"
#import "VDESourceCodeEditorView.h"
#import "VDETextSiderBarView.h"

@interface VDESourceScrollView()
{
@private
    VDETextSiderBarView *_lineNumberView;
}
@end

@implementation VDESourceScrollView

static void VDESourceScrollViewCommonInitialize(VDESourceScrollView *self)
{
    self->_editorView = [[VDESourceCodeEditorView alloc] initWithFrame: [self bounds]];
    
    [self setDocumentView: self->_editorView];

    self->_lineNumberView = [[VDETextSiderBarView alloc] initWithScrollView: self
                                                                orientation: NSVerticalRuler];
    [self setVerticalRulerView: self->_lineNumberView];
    [self setHasVerticalRuler: YES];
    [self setHasHorizontalRuler: NO];
    [self setRulersVisible: YES];
    
}

- (void)dealloc
{
    [_lineNumberView release];
    [_editorView release];
    
    [super dealloc];
}

- (id)initWithFrame: (NSRect)frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        VDESourceScrollViewCommonInitialize(self);
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        VDESourceScrollViewCommonInitialize(self);
    }
    
    return self;
}

- (VDESourceCodeEditorView *)editorView
{
    return _editorView;
}

@end
