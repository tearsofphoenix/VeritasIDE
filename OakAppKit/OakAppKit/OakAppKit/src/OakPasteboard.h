

extern NSString*  NSReplacePboard;
extern NSString*  OakPasteboardDidChangeNotification;

extern NSString*  kUserDefaultsFindWrapAround;
extern NSString*  kUserDefaultsFindIgnoreCase;

extern NSString*  OakFindIgnoreWhitespaceOption;
extern NSString*  OakFindFullWordsOption;
extern NSString*  OakFindRegularExpressionOption;

@interface OakPasteboardEntry : NSObject
{
	NSString* string;
	NSMutableDictionary* options;
}
+ (OakPasteboardEntry*)pasteboardEntryWithString:(NSString*)aString;
+ (OakPasteboardEntry*)pasteboardEntryWithString:(NSString*)aString andOptions:(NSDictionary*)someOptions;

@property (nonatomic, copy) NSString* string;
@property (nonatomic, copy) NSDictionary* options;

@property (nonatomic, assign) BOOL fullWordMatch;
@property (nonatomic, assign) BOOL ignoreWhitespace;
@property (nonatomic, assign) BOOL regularExpression;

@property (nonatomic) NSStringCompareOptions findOptions;

@end

@interface OakPasteboard : NSObject
{
@private
	NSString* pasteboardName;
	NSMutableArray* entries;
	NSDictionary* auxiliaryOptionsForCurrent;
	NSUInteger index;
	NSInteger changeCount;
	BOOL avoidsDuplicates;
}
+ (OakPasteboard*)pasteboardWithName:(NSString*)aName;
- (void)addEntry:(OakPasteboardEntry*)anEntry;

@property (nonatomic, assign) BOOL avoidsDuplicates;

- (OakPasteboardEntry*)previous;
- (OakPasteboardEntry*)current;
- (OakPasteboardEntry*)next;

@property (nonatomic, retain) NSDictionary* auxiliaryOptionsForCurrent;

- (void)selectItemAtPosition:(NSPoint)aLocation andCall:(SEL)aSelector;
- (void)selectItemForControl:(NSView*)controlView;
@end
