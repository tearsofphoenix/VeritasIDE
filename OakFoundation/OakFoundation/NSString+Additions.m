#import "NSString+Additions.h"
#import "OakFoundation.h"

@implementation NSString (Path)

+ (NSString*)stringWithUTF8String: (char const*)aString
                           length: (NSUInteger)aLength
{
	return [[[NSString alloc] initWithBytes: aString
                                     length: aLength
                                   encoding: NSUTF8StringEncoding] autorelease];
}

- (BOOL)existsAsPath
{
	return [[NSFileManager defaultManager] fileExistsAtPath: self];
}

- (BOOL)isDirectory
{
	BOOL isDir = NO;
	return [[NSFileManager defaultManager] fileExistsAtPath: self
                                                isDirectory: &isDir] && isDir;
}

- (NSString *)stringByConvertToEncoding: (NSStringEncoding)encoding
                           fromEncoding: (NSStringEncoding)fromEncoding
{
    NSData *data = [self dataUsingEncoding: fromEncoding];
    
    return [[[NSString alloc] initWithData: data
                                  encoding: encoding] autorelease];
}

+ (NSString *)stringWithChar: (char)value
                 repeatCount: (NSUInteger)count
{
    char *cstr = malloc(sizeof(char) * count + 1);
    memset(cstr, value, sizeof(char) * count);
    cstr[count] = '\0';
    
    NSString *result = [NSString stringWithUTF8String: cstr];
    
    free(cstr);
    
    return result;
}

- (NSUInteger)locationOfLineStart: (NSUInteger)line
{
    const char *cString = [self UTF8String];
    const char *charLooper = cString;
    
    NSUInteger lineCounter = 0;
    
    while (charLooper)
    {
        if (lineCounter == line)
        {
            return charLooper - cString;
        }

        if (*charLooper == '\n')
        {
            ++lineCounter;
        }
        
        ++charLooper;
    }
    
    return NSNotFound;
}

- (NSUInteger)locationOfLineEnd: (NSUInteger)line
{
    NSUInteger idx = [self locationOfLineStart: line + 1];
    if (idx == NSNotFound)
    {
        return NSNotFound;
    }
    
    return idx - 1;
}

- (NSUInteger)numberOfLines
{
    const char *cStr = [self UTF8String];
    NSUInteger lineCount = 0;

    while (cStr)
    {
        if (*cStr == '\n')
        {
            ++lineCount;
        }
        
        ++cStr;
    }
    
    return lineCount;
}

- (char)charAtIndex: (NSUInteger)index
{
    return [self UTF8String][index];
}

@end

@implementation NSString (FinderSorting)

- (NSComparisonResult)displayNameCompare: (NSString*)otherString
{
	static NSStringCompareOptions comparisonOptions = (NSCaseInsensitiveSearch
                                                       | NSNumericSearch
                                                       | NSWidthInsensitiveSearch
                                                       | NSForcedOrderingSearch);
	return [self compare: otherString
                 options: comparisonOptions
                   range: NSMakeRange(0, self.length)
                  locale: [NSLocale currentLocale]];
}
@end
