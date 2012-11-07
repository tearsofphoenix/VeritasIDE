#import "OakStringListTransformer.h"

@interface OakStringListTransformer ()

@property (nonatomic, retain) NSArray* stringList;

@end

@implementation OakStringListTransformer

@synthesize stringList = _stringList;

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (void)createTransformerWithName: (NSString*)aName
                  andObjectsArray: (NSArray*)aList
{
	if([NSValueTransformer valueTransformerForName: aName])
    {
		return;
    }
    
	OakStringListTransformer* transformer = [[OakStringListTransformer alloc] init];
	[transformer setStringList: aList];
    
	[NSValueTransformer setValueTransformer: transformer
                                    forName: aName];
    [transformer release];
}

+ (void)createTransformerWithName: (NSString*)aName
                       andObjects: (id)firstObj, ...
{
	va_list ap;
	va_start(ap, firstObj);
	
    NSMutableArray* list = [NSMutableArray array];
	do
    {
		[list addObject: firstObj];
        
	} while((firstObj = va_arg(ap, id)));
    
	va_end(ap);

	[self createTransformerWithName: aName
                    andObjectsArray: list];
}

- (id)transformedValue:(id)value
{
	NSUInteger i = value ? [_stringList indexOfObject: value] : NSNotFound;
	return i != NSNotFound ? @(i) : nil;
}

- (id)reverseTransformedValue: (id)value
{
	NSUInteger i = value ? [value unsignedIntValue] : NSNotFound;
	return i < [_stringList count] ? [_stringList objectAtIndex: i] : nil;
}
@end
