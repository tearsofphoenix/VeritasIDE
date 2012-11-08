
@interface NSString (Path)

+ (NSString*)stringWithUTF8String: (char const *)aString
                           length: (NSUInteger)aLength;

- (NSString *)stringByConvertToEncoding: (NSStringEncoding)encoding
                           fromEncoding: (NSStringEncoding)fromEncoding;

+ (NSString *)stringWithChar: (char)value
                 repeatCount: (NSUInteger)count;

- (char)charAtIndex: (NSUInteger)index;

- (BOOL)existsAsPath;

- (BOOL)isDirectory;


@end

@interface NSString (DocumentContent)

- (NSUInteger)locationOfLineStart: (NSUInteger)line;

- (NSUInteger)locationOfLineEnd: (NSUInteger)line;

- (NSUInteger)numberOfLines;

@end

@interface NSString (FinderSorting)

- (NSComparisonResult)displayNameCompare: (NSString*)otherString;

@end
