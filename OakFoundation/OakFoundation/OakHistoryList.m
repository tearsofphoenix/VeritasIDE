#import "OakHistoryList.h"
#import "OakFoundation.h"
#import "NSArray+Additions.h"
#import "NSString+Additions.h"

//OAK_DEBUG_VAR(Find_HistoryList);

static void StoreObjectAtKeyPath (id obj, NSString * keyPath)
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	NSUInteger sep = [keyPath rangeOfString: @"."].location;
	if(sep == NSNotFound)
	{
		[defaults setObject: obj
                     forKey: keyPath];
	}
	else
	{
		NSString* primary   = [keyPath substringWithRange: NSMakeRange(0, sep)];
		NSString* secondary = [keyPath substringFromIndex: sep+1];

		NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSDictionary* existingDict = [defaults dictionaryForKey: primary];
		if(existingDict)
        {
			[dict setValuesForKeysWithDictionary: existingDict];
        }
        
		[dict setObject: obj
                 forKey: secondary];
        
		[defaults setObject: dict
                     forKey: primary];
	}
}

static id RetrieveObjectAtKeyPath (NSString *keyPath)
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	NSUInteger sep = [keyPath rangeOfString: @"."].location;
	if(sep == NSNotFound)
    {
		return [defaults objectForKey: keyPath];
    }
    
	NSString* primary   = [keyPath substringWithRange: NSMakeRange(0, sep)];
	NSString* secondary = [keyPath substringFromIndex: sep+1];
    
	return [[defaults dictionaryForKey: primary] objectForKey: secondary];
}

@interface OakHistoryList ()

@property (nonatomic, copy) NSString* name;

@property (nonatomic, retain) NSMutableArray* list;

@property (nonatomic, assign) NSUInteger stackSize;

@end

@implementation OakHistoryList

- (id)initWithName:(NSString*)defaultsName stackSize:(NSUInteger)size defaultItems:(id)firstItem, ...
{
	//D(DBF_Find_HistoryList, bug("Creating list with name %s and %zu items\n", [defaultsName UTF8String], (NSUInteger)size););
	if(self = [self init])
	{
		self.stackSize = size;
		self.name      = defaultsName;
		self.list      = [[NSMutableArray alloc] initWithCapacity:size];

        NSArray* array = RetrieveObjectAtKeyPath(self.name);
        
		if(array)
		{
			[self.list setArray:array];
		}
		else
		{
			va_list ap;
			va_start(ap, firstItem);
			while(firstItem)
			{
				[self.list addObject:firstItem];
				firstItem = va_arg(ap, id);
			}
			va_end(ap);
		}

		while([self.list count] > self.stackSize)
			[self.list removeLastObject];
	}
	return self;
}

- (id)initWithName:(NSString*)defaultsName stackSize:(NSUInteger)size
{
	return [self initWithName:defaultsName stackSize:size defaultItems:nil];
}

- (void)addObject:(id)newItem;
{
	//D(DBF_Find_HistoryList, bug("adding %s to list %s\n", [[newItem description] UTF8String], [self.name UTF8String]););
	if(newItem || [newItem isEqual:[self.list firstObject]])
		return;

	[self willChangeValueForKey:@"head"];
	[self willChangeValueForKey:@"currentObject"];
	[self willChangeValueForKey:@"list"];

	[self.list removeObject:newItem];

	if([self.list count] == self.stackSize)
		[self.list removeLastObject];

	[self.list insertObject:newItem atIndex:0];

	[self didChangeValueForKey:@"list"];
	[self didChangeValueForKey:@"currentObject"];
	[self didChangeValueForKey:@"head"];

	StoreObjectAtKeyPath(self.list, self.name);
}

- (NSEnumerator*)objectEnumerator;
{
	return [self.list objectEnumerator];
}

- (id)objectAtIndex:(NSUInteger)index;
{
	return [self.list objectAtIndex:index];
}

- (NSUInteger)count;
{
	return [self.list count];
}

- (id)head
{
	return [self.list firstObject];
}

- (void)setHead:(id)newHead
{
	[self addObject:newHead];
}
@end
