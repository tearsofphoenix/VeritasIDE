#include "clipboard.h"

@implementation OakClipBoardEntry

- (id)initWithContent: (NSString *)content
{
    if ((self = [super init]))
    {
        _content = [content retain];
    }
    
    return self;
}

- (NSString *)content
{
    return _content;
}

- (NSDictionary *)options
{
    return [NSDictionary dictionary];
}

@end

@interface OakSimpleClipboard : NSObject<OakClipBoard>
{
    NSMutableArray *_entryStack;
	NSUInteger _index;
    
}
@end

@implementation OakSimpleClipboard

- (id)init
{
    if ((self = [super init]))
    {
        _index = 0;
        _entryStack = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)isEmpty
{
    return [_entryStack count] == 0;
}

- (OakClipBoardEntry *)previous
{
    return (0 == _index) ? nil : [_entryStack objectAtIndex: --_index];
}

- (OakClipBoardEntry *)current
{
    return ([_entryStack count] == _index) ? nil : [_entryStack objectAtIndex: _index];
}

- (OakClipBoardEntry *)next
{
    return  (_index + 1 >= [_entryStack count]) ? nil : [_entryStack objectAtIndex: ++_index];
}

- (void)addEntry: (OakClipBoardEntry *)entry
{
    [_entryStack addObject: entry];
    _index = [_entryStack count] - 1;
}

@end

id<OakClipBoard> OakCreateSimpleClipboard (void)
{
	return [[[OakSimpleClipboard alloc] init] autorelease];
}
