
@interface NSString (Path)

+ (NSString*)stringWithUTF8String: (char const *)aString
                           length: (NSUInteger)aLength;

- (BOOL)existsAsPath;

- (BOOL)isDirectory;

- (NSString *)stringByConvertToEncoding: (NSStringEncoding)encoding
                           fromEncoding: (NSStringEncoding)fromEncoding;

+ (NSString *)stringWithChar: (char)value
                 repeatCount: (NSUInteger)count;

- (NSUInteger)locationOfLineStart: (NSUInteger)line;

- (NSUInteger)locationOfLineEnd: (NSUInteger)line;

- (NSUInteger)numberOfLines;

- (char)charAtIndex: (NSUInteger)index;

@end

@interface NSString (FinderSorting)

- (NSComparisonResult)displayNameCompare: (NSString*)otherString;

@end
