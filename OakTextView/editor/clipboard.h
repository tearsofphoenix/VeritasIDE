
@interface OakClipBoardEntry : NSObject
{
    NSString * _content;
}

- (id)initWithContent: (NSString *)content;

- (NSString *)content;

- (NSDictionary *)options;

@end

@protocol OakClipBoard<NSObject>

- (BOOL)isEmpty;

- (OakClipBoardEntry *)previous;

- (OakClipBoardEntry *)current;

- (OakClipBoardEntry *)next;

- (void)addEntry: (OakClipBoardEntry *)entry;

//- (void)addEntryWithString: (NSString *)entry;

@end

extern id<OakClipBoard> OakCreateSimpleClipboard(void);
