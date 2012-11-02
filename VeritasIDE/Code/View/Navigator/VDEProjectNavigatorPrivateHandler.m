//
//  VDEProjectNavigatorPrivateHandler.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import "VDEProjectNavigatorPrivateHandler.h"
#import "VDEProjectNavigatorView.h"
#import "VDEProjectConfiguration.h"
#import "VDEDataService.h"
#import "VDEImageTextCell.h"
#import "VXGroup.h"
#import "VXFileReference.h"
#import "VDEResourceService.h"
#import "VDENotificationService.h"

#define COLUMNID_NAME			@"NameColumn"	// the single column name in our outline view

@interface VDEProjectNavigatorPrivateHandler ()<NSOutlineViewDataSource, NSOutlineViewDelegate>
{
@private
    NSOutlineView    *_outlineView;
    VDEImageTextCell *separatorCell;	// the cell used to draw a separator line in the outline view
    NSMutableSet     *_selectedItems;
}
@end

@implementation VDEProjectNavigatorPrivateHandler

- (id)initWithOutlineView: (NSOutlineView *)outlineView
{
    if ((self = [super init]))
    {
        _outlineView = outlineView;
        [_outlineView setDataSource: self];
        [_outlineView setDelegate: self];
        
        // apply our custom VDEImageTextCell for rendering the first column's cells
        //
        NSTableColumn *tableColumn = [_outlineView tableColumnWithIdentifier: COLUMNID_NAME];
        
        VDEImageTextCell *imageTextCell = [[VDEImageTextCell alloc] init];
        [imageTextCell setEditable: YES];
        
        [tableColumn setDataCell: imageTextCell];
        
        [imageTextCell release];
        
        separatorCell = [[VDEImageTextCell alloc] init];
        [separatorCell setEditable:NO];
        
        _selectedItems = [[NSMutableSet alloc] init];
        
        [[VDENotificationService serviceCenter] addObserver: self
                                                   selector: @selector(notificationForDidLoadProject:)
                                                       name: VDEDataServiceDidLoadProjectNotification
                                                     object: nil];
    }
    
    return self;
}

- (void)dealloc
{
    [_selectedItems release];
    
    [super dealloc];
}

- (void)notificationForDidLoadProject: (NSNotification *)notification
{
    [self setProjectConfiguration: [[notification userInfo] objectForKey: @"project"]];
}

@synthesize projectConfiguration = _projectConfiguration;

- (void)setProjectConfiguration: (VDEProjectConfiguration *)projectConfiguration
{
    if (_projectConfiguration != projectConfiguration)
    {
        _projectConfiguration = projectConfiguration;
        
        [_outlineView reloadData];
    }
}

#pragma mark - NSOutlineView DataSource

- (NSInteger)outlineView: (NSOutlineView *)outlineView
  numberOfChildrenOfItem: (id)item
{
    if (item)
    {
        return [[item children] count];
    }else
    {
        //the root object
        //
        if(_projectConfiguration)
        {
            return 1;
            
        }else
        {
            return 0;
        }
    }
}

- (BOOL)outlineView: (NSOutlineView *)outlineView
   isItemExpandable: (id)item
{
    if (item)
    {
        return  [[item children] count] > 0;
        
    }else
    {
        //root object is expandable
        //
        return YES;
    }
}

- (id)outlineView: (NSOutlineView *)outlineView
            child: (NSInteger)index
           ofItem: (id)item
{
    if (item)
    {
        return [[item children] objectAtIndex: index];
        
    }else
    {
        //return root object
        return [_projectConfiguration mainGroup];
    }
}

- (id)        outlineView: (NSOutlineView *)outlineView
objectValueForTableColumn: (NSTableColumn *)tableColumn
                   byItem: (id)item
{
    if (item)
    {
        NSString *name = [item valueForKey: @"name"];
        if (!name)
        {
            name = [item valueForKey: @"path"];
        }
        return name;
    }else
    {
        return @"ok";
    }
}

- (void)outlineView: (NSOutlineView *)outlineView
     setObjectValue: (id)object
     forTableColumn: (NSTableColumn *)tableColumn
             byItem: (id)item
{
    if ([[tableColumn identifier] isEqualToString: COLUMNID_NAME])
    {
        VXDictObject *dictObject = item;
        [dictObject setName: object];
    }
}

#pragma mark - NSOutlineView delegate

- (NSIndexSet *)         outlineView: (NSOutlineView *)outlineView
selectionIndexesForProposedSelection: (NSIndexSet *)proposedSelectionIndexes
{
    [_selectedItems removeAllObjects];
    
    [proposedSelectionIndexes enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                                           {
                                                               [_selectedItems addObject: [_outlineView itemAtRow: idx]];
                                                               
                                                           })];
    
    if ([_selectedItems count] == 1)
    {
        id item = [_selectedItems anyObject];
        if ([item isKindOfClass: [VXFileReference class]])
        {
            [[VDENotificationService serviceCenter] postNotificationName: VDEProjectNavigatorViewDidSelectSingleFileNotification
                                                                  object: self
                                                                userInfo: (@{            @"item" : item,
                                                                           @"configuration" : _projectConfiguration
                                                                           })];
        }
    }
    
    return proposedSelectionIndexes;
}

- (NSCell *)outlineView: (NSOutlineView *)outlineView
 dataCellForTableColumn: (NSTableColumn *)tableColumn
                   item: (id)item
{
	NSCell *returnCell = [tableColumn dataCell];
	
	if ([[tableColumn identifier] isEqualToString: COLUMNID_NAME])
	{
		// we are being asked for the cell for the single and only column
        
		if ([self isSeparator: item])
        {
            returnCell = separatorCell;
        }
	}
	
	return returnCell;
}

- (BOOL)     control: (NSControl *)control
textShouldEndEditing: (NSText *)fieldEditor
{
    // don't allow empty node names
    //
	return ([[fieldEditor string] length] > 0);
}

- (BOOL)   outlineView: (NSOutlineView *)outlineView
 shouldEditTableColumn: (NSTableColumn *)tableColumn
                  item: (id)item
{
	return YES;
}

- (void)outlineView: (NSOutlineView *)olv
    willDisplayCell: (NSCell*)cell
     forTableColumn: (NSTableColumn *)tableColumn
               item: (id)item
{
	if ([[tableColumn identifier] isEqualToString: COLUMNID_NAME])
	{
		// we are displaying the single and only column
		if ([cell isKindOfClass: [VDEImageTextCell class]])
		{
			// set the cell's image
            [cell setEditable: YES];
			[(VDEImageTextCell*)cell setImage: [item icon]];
		}
	}
}

- (void)outlineViewSelectionDidChange: (NSNotification *)notification
{
    
}


#pragma mark - helper

- (BOOL)isSeparator: (id)item
{
    return NO;
}

@end
