//
//  VDEProjectNavigatorView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import "VDEProjectNavigatorView.h"
#import "VDEProjectNavigatorPrivateHandler.h"
#import "VDEImageTextCell.h"

#define kNodesPBoardType		@"myNodesPBoardType"	// drag and drop pasteboard type


@interface VDEProjectNavigatorView ()
{
@private
    VDEProjectNavigatorPrivateHandler *_dataSource;
}

@end

@implementation VDEProjectNavigatorView

@synthesize projectConfiguration = _projectConfiguration;

- (id)initWithCoder: (NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self)
    {        
        _outlineView = [self documentView];
        [_outlineView setBackgroundColor: [NSColor colorWithCalibratedRed: 239.0 / 255.0
                                                                   green: 239.0 / 255.0
                                                                    blue: 239.0 / 255.0
                                                                    alpha: 1.0]];
        
        // scroll to the top in case the outline contents is very long
        [[[_outlineView enclosingScrollView] verticalScroller] setFloatValue:0.0];
        [[[_outlineView enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0,0)];
        
        // make our outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
        [_outlineView setSelectionHighlightStyle: NSTableViewSelectionHighlightStyleSourceList];
        
        // drag and drop support
        [_outlineView registerForDraggedTypes: @[
                                                 kNodesPBoardType,			// our internal drag type
                                                 NSURLPboardType,			// single url from pasteboard
                                                 NSFilenamesPboardType,		// from Safari or Finder
                                                 NSFilesPromisePboardType,	// from Safari or Finder (multiple URLs)
                                                 ]];        
    }
    
    return self;
}

- (void)setProjectConfiguration: (VDEProjectConfiguration *)projectConfiguration
{
    if (_projectConfiguration != projectConfiguration)
    {
        [_projectConfiguration release];
        _projectConfiguration = [projectConfiguration retain];
        
        if (!_dataSource)
        {
            _dataSource = [[VDEProjectNavigatorPrivateHandler alloc] initWithOutlineView: _outlineView];
        }
        
        [_dataSource setProjectConfiguration: _projectConfiguration];
    }
}

@end

NSString * VDEProjectNavigatorViewDidSelectSingleFileNotification = @"navigatorView.notification.didSelectSingleFile";
