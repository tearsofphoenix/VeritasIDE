#import "snippets.h"
#import "OakSnippet.h"
#import <OakFoundation/OakFoundation.h>

@implementation OakSnippetController

- (id)init
{
    if((self = [super init]))
    {
        _stack = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_stack release];
    
    [super dealloc];
}

- (void)pushSnippet: (OakSnippet *)snippet
            toRange: (OakTextRange *)range
	{
		if([_stack count] == 0)
        {
            _anchor = [[range minPosition] index];
        }
        
		[_stack addObject: @[snippet, [Ol](range.first.index - anchor, range.last.index - anchor ]];
	}

	std::vector< std::pair<ng::range_t, NSString *> > snippet_controller_t::replace (NSUInteger from, NSUInteger to, NSString * replacement)
	{
		if(stack.empty())
			return std::vector< std::pair<ng::range_t, NSString *> >(1, std::make_pair(ng::range_t(from, to), replacement));

		std::vector< std::pair<ng::range_t, NSString *> > res;
		citerate(pair, stack.replace(snippet::range_t(from - anchor, to - anchor), replacement))
			res.push_back(std::make_pair(ng::range_t(pair->first.from.offset + anchor, pair->first.to.offset + anchor), pair->second));
		return res;
	}

	ng::range_t snippet_controller_t::current () const
	{
		snippet::range_t  range = stack.current();
		return ng::range_t(range.from.offset + anchor, range.to.offset + anchor, false, false, range.from.offset != range.to.offset ? true : false);
	}

	std::vector<NSString *>  snippet_controller_t::choices () const
	{
		return stack.choices();
	}

	void snippet_controller_t::drop_for_pos (NSUInteger pos)
	{
		if(!stack.empty())
			stack.drop_for_pos(pos - anchor);
	}

@end