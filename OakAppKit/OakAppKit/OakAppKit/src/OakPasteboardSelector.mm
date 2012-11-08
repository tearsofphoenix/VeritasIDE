/*
	TODO Drag’n’drop
	TODO Show some sort of title
	TODO Filter string
*/

#import "OakPasteboardSelector.h"
#import "OakFunctions.h"


static NSUInteger line_count (NSString * text)
{
    const char *cString = [text UTF8String];
    NSUInteger count = 0;
    
    while (cString)
    {
        if ('\n' == *cString)
        {
            ++count;
        }
        
        ++cString;
    }
    
    return count;
}

@interface OakPasteboardSelectorMultiLineCell : NSCell
{
	NSUInteger maxLines;
}
@property (nonatomic, assign) NSUInteger maxLines;
+ (id)cellWithMaxLines:(NSUInteger)maxLines;
- (CGFloat)rowHeightForText:(NSString*)text;
@end

@implementation OakPasteboardSelectorMultiLineCell
@synthesize maxLines;

+ (id)cellWithMaxLines:(NSUInteger)maxLines;
{
	OakPasteboardSelectorMultiLineCell* cell = [[[self class] new] autorelease];
	cell.maxLines = maxLines;
	return cell;
}

- (NSDictionary*)textAttributes;
{
	static NSMutableParagraphStyle* const style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	if([self isHighlighted])
	{
		static NSDictionary* const highlightedAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSColor alternateSelectedControlTextColor], NSForegroundColorAttributeName,
			style, NSParagraphStyleAttributeName,
			nil];
		return highlightedAttributes;
	}
	else
	{
		static NSDictionary* const attributes = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
		return attributes;
	}
}

- (NSUInteger)lineCountForText:(NSString*)text
{
	return OakCap((NSUInteger)1, line_count(text), maxLines);
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView*)controlView
{
	NSArray* lines        = [[self objectValue] componentsSeparatedByString:@"\n"];
	NSArray* clippedLines = [lines subarrayWithRange:NSMakeRange(0, [self lineCountForText:[self objectValue]])];
	NSRect rowFrame       = frame;
	rowFrame.size.height  = [[lines objectAtIndex:0] sizeWithAttributes:[self textAttributes]].height;
	for(NSUInteger index = 0; index < [clippedLines count]; ++index)
	{
		if(index == [clippedLines count] - 1 && [clippedLines count] < [lines count])
		{
			NSString* moreLinesText           = [NSString stringWithFormat:@"%lu more line%s", [lines count] - [clippedLines count], ([lines count] - [clippedLines count]) != 1 ? "s" : ""];
			NSDictionary* moreLinesAttributes = @{ NSForegroundColorAttributeName : ([self isHighlighted] ? [NSColor darkGrayColor] : [NSColor lightGrayColor]) };
			NSAttributedString* moreLines     = [[[NSAttributedString alloc] initWithString:moreLinesText
                                                                              attributes:moreLinesAttributes] autorelease];
			NSSize size             = [moreLines size];
			NSRect moreLinesRect    = rowFrame;
			moreLinesRect.origin.x += frame.size.width - size.width;
			moreLinesRect.size      = size;
			rowFrame.size.width    -= size.width + 5;
			[moreLines drawInRect:moreLinesRect];
		}
		[[clippedLines objectAtIndex:index] drawInRect:rowFrame withAttributes:[self textAttributes]];
		rowFrame.origin.y += rowFrame.size.height;
	}
}

- (CGFloat)rowHeightForText:(NSString*)text;
{
	NSArray* lines = [text componentsSeparatedByString:@"\n"];
	CGFloat height = [self lineCountForText:text] * [[lines objectAtIndex:0] sizeWithAttributes:[self textAttributes]].height;
	if(height == 0)
		height = 15; // FIXME magic number (see commit log for details)
	return height;
}
@end

@interface OakPasteboardSelectorTableViewHelper : NSResponder <NSTableViewDataSource, NSTableViewDelegate>
{
	NSTableView* tableView;
	NSMutableArray* entries;
	BOOL shouldClose;
	BOOL shouldSendAction;
}
- (void)setTableView:(NSTableView*)aTableView;
@end

@implementation OakPasteboardSelectorTableViewHelper
- (id)initWithEntries:(NSArray*)someEntries
{
	if(self = [super init])
	{
		entries = [someEntries mutableCopy];
	}
	return self;
}

- (void)dealloc
{
	[self setTableView:nil];
	[entries release];
	[super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)aTableView
{
	return [entries count];
}

- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex
{
	return [[[entries objectAtIndex:rowIndex] string] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (CGFloat)tableView:(NSTableView*)aTableView heightOfRow:(NSInteger)rowIndex
{
	NSString* text = [self tableView:aTableView objectValueForTableColumn:nil row:rowIndex];
	return [[[[aTableView tableColumns] objectAtIndex:0] dataCell] rowHeightForText:text];
}

- (void)setTableView:(NSTableView*)aTableView
{
	if(tableView && tableView == aTableView)
		return;

	if(tableView)
	{
		[tableView setDelegate:nil];
		[tableView setTarget:nil];
		[tableView setDataSource:nil];
		[tableView setNextResponder:[self nextResponder]];
		[tableView release];
	}

	if(aTableView)
	{
		tableView = [aTableView retain];

		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView reloadData];
		[tableView setUsesAlternatingRowBackgroundColors:YES];
		[[[tableView tableColumns] objectAtIndex:0] setDataCell:[OakPasteboardSelectorMultiLineCell cellWithMaxLines:3]];

		NSResponder* nextResponder = [tableView nextResponder];
		[tableView setNextResponder:self];
		[self setNextResponder:nextResponder];

		[tableView setTarget:self];
		[tableView setDoubleAction:@selector(didDoubleClickInTableView:)];
		[tableView setAction:NULL];
	}
}

- (void)setPerformsActionOnSingleClick
{
	[tableView setAction:@selector(didDoubleClickInTableView:)];
}

- (void)deleteBackward:(id)sender
{
	int selectedRow = (int)[tableView selectedRow];
	if(selectedRow == -1 || [entries count] <= 1)
		return NSBeep();
	[entries removeObjectAtIndex:selectedRow];
	[tableView reloadData];
	if([entries count] > 0)
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:OakCap(0, selectedRow - 1, (int)[entries count]-1)] byExtendingSelection:NO];
}

- (void)deleteForward:(id)sender
{
	NSInteger selectedRow = [tableView selectedRow];
	if(selectedRow == -1 || [entries count] <= 1)
		return NSBeep();
	[entries removeObjectAtIndex:selectedRow];
	[tableView reloadData];
	if([entries count] > 0)
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:MIN(selectedRow, [entries count]-1)] byExtendingSelection:NO];
}

- (void)insertNewline:(id)sender
{
	shouldSendAction = entries.count > 0 ? YES : NO;
	shouldClose = YES;
}

- (void)cancel:(id)sender
{
	shouldClose = YES;
}

- (void)keyDown:(NSEvent*)anEvent
{
	[self interpretKeyEvents:@[ anEvent ]];
}

- (void)moveSelectedRowByOffset:(NSInteger)anOffset
{
	if(tableView.numberOfRows > 0)
	{
		NSInteger row = OakCap(0, tableView.selectedRow + anOffset, tableView.numberOfRows - 1);
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[tableView scrollRowToVisible:row];
	}
}

- (int)visibleRows                             { return (int)floorf(NSHeight([tableView visibleRect]) / ([tableView rowHeight]+[tableView intercellSpacing].height)) - 1; }

- (void)moveUp:(id)sender                      { [self moveSelectedRowByOffset:-1]; }
- (void)moveDown:(id)sender                    { [self moveSelectedRowByOffset:+1];}
- (void)movePageUp:(id)sender                  { [self moveSelectedRowByOffset:-[self visibleRows]]; }
- (void)movePageDown:(id)sender                { [self moveSelectedRowByOffset:+[self visibleRows]]; }
- (void)scrollToBeginningOfDocument:(id)sender { [self moveSelectedRowByOffset:-(INT_MAX >> 1)]; }
- (void)scrollToEndOfDocument:(id)sender       { [self moveSelectedRowByOffset:+(INT_MAX >> 1)]; }

- (void)pageUp:(id)sender                      { [self movePageUp:sender]; }
- (void)pageDown:(id)sender                    { [self movePageDown:sender]; }
- (void)scrollPageUp:(id)sender                { [self movePageUp:sender]; }
- (void)scrollPageDown:(id)sender              { [self movePageDown:sender]; }

- (void)didDoubleClickInTableView:(id)aTableView
{
	shouldClose = shouldSendAction = YES;
}

- (BOOL)shouldSendAction
{
	return shouldSendAction;
}

- (BOOL)shouldClose
{
	return shouldClose;
}

- (NSArray*)entries
{
	return entries;
}
@end

static OakPasteboardSelector* SharedInstance;

@implementation OakPasteboardSelector
+ (OakPasteboardSelector*)sharedInstance
{
	return SharedInstance ?: [[OakPasteboardSelector new] autorelease];
}

- (id)init
{
	if(SharedInstance)
	{
		[self release];
	}
	else if((self = SharedInstance = [[super initWithWindowNibName:@"Pasteboard Selector"] retain]))
	{
		[self setShouldCascadeWindows:NO];
		[self window];
	}
	return SharedInstance;
}

- (void)dealloc
{
	[tableViewHelper release];
	[super dealloc];
}

- (void)setIndex:(NSUInteger)index
{
	[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}

- (void)setEntries:(NSArray*)entries
{
	[self setIndex:0];
	[tableViewHelper release];
	tableViewHelper = [[OakPasteboardSelectorTableViewHelper alloc] initWithEntries:entries];
	[tableViewHelper setTableView:tableView];
}

- (NSArray*)entries
{
	return [tableViewHelper entries];
}

- (NSUInteger)showAtLocation:(NSPoint)aLocation
{
	NSWindow* parentWindow = [NSApp keyWindow];
	NSWindow* window = [self window];
	[window setFrameTopLeftPoint:aLocation];
	[parentWindow addChildWindow:window ordered:NSWindowAbove];
	[window orderFront:self];
	[tableView scrollRowToVisible:tableView.selectedRow];

	while(NSEvent* event = [NSApp nextEventMatchingMask: NSAnyEventMask
                                              untilDate: [NSDate distantFuture]
                                                 inMode: NSDefaultRunLoopMode
                                                dequeue: YES])
	{
		static NSArray * keyEvent   = @[ @(NSKeyDown), @(NSKeyUp) ];
		static NSArray * mouseEvent = (@[  @(NSLeftMouseDown),
                                           @(NSLeftMouseUp),
                                           @(NSRightMouseDown),
                                            @(NSRightMouseUp),
                                            @(NSOtherMouseDown),
                                           @(NSOtherMouseUp)]);

		BOOL orderOutEvent = (([keyEvent containsObject: @([event type])]
                              && [event window] != parentWindow)
                              || ([mouseEvent containsObject: @([event type])]
                                  && [event window] != window));
        
		if(!orderOutEvent
           && [keyEvent containsObject: @([event type]) ]
           && !([event modifierFlags] & NSCommandKeyMask))
        {
				[window sendEvent:event];
            
        }else
        {
            [NSApp sendEvent:event];
        }

		if(orderOutEvent || [tableViewHelper shouldClose])
			break;
	}

	[parentWindow removeChildWindow:window];
	[window orderOut:self];

	return [tableView selectedRow];
}

- (void)setWidth:(CGFloat)width;
{
	NSRect frame = [[self window] frame];
	frame.size.width = width;
	[[self window] setFrame:frame display:NO];
}

- (void)setPerformsActionOnSingleClick
{
	[tableViewHelper setPerformsActionOnSingleClick];
}

- (BOOL)shouldSendAction
{
	return [tableViewHelper shouldSendAction];
}
@end
