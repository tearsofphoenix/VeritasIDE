
@class OakSnippet;
@class OakTextRange;

@interface OakSnippetController : NSObject
{
    NSUInteger _anchor;
    NSMutableArray *_stack;
}

- (void)pushSnippet: (OakSnippet *)snippet
            toRange: (OakTextRange *)range;

- (NSArray *)replaceFrom: (NSUInteger)from
                      to: (NSUInteger)to
                    with: (NSString *)replacement;

- (OakTextRange *)currentRange;

- (NSArray *)choices;

- (void)dropForPosition: (NSUInteger)pos;

- (BOOL)next;

- (BOOL)previous;

- (void)clear;

- (BOOL)isEmpty;

- (BOOL)isInLastPlaceholder;

@end
