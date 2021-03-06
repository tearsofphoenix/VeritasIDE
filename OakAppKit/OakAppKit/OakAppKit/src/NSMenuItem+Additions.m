#import "NSMenu+Additions.h"
#import "OakFileIconImage.h"
#import <OakFoundation/OakFoundation.h>
#import <OakFoundation/NSString+Additions.h>
//#import <text/case.h>
//

@interface MenuMutableAttributedString : NSMutableAttributedString
{
	NSMutableAttributedString* contents;
	CGSize size;
}
- (void)appendTableCellWithString:(NSString*)string table:(NSTextTable*)table textAlignment:(NSTextAlignment)textAlignment verticalAlignment:(NSTextBlockVerticalAlignment)verticalAlignment font:(NSFont*)font row:(int)row column:(int)column;
- (CGSize)size;
@end

@implementation MenuMutableAttributedString

// Methods to override in subclass

- (id)init
{
	return [self initWithAttributedString:nil];
}

- (id)initWithAttributedString:(NSAttributedString*)attributedString
{
	if(self = [super init])
		contents = attributedString ? [attributedString mutableCopy] : [[NSMutableAttributedString alloc] init];
	return self;
}

- (NSString*)string
{
	return [contents string];
}

- (NSDictionary*)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRange*)range
{
	return [contents attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString*)string
{
	[contents replaceCharactersInRange:range withString:string];
}

- (void)setAttributes:(NSDictionary*)attributes range:(NSRange)range
{
	[contents setAttributes:attributes range:range];
}

- (id)copyWithZone:(NSZone*)zone
{
	MenuMutableAttributedString* copy = [MenuMutableAttributedString allocWithZone:zone];
	copy->contents = [contents copyWithZone:zone];
	copy->size = size;
	return copy;
}

- (void)dealloc
{
	[contents release];
	[super dealloc];
}

// NOTE: AppKit additions produce invalid values here, provide our own implementation

- (NSRect)boundingRectWithSize:(NSSize)aSize options:(NSStringDrawingOptions)options
{
	return NSMakeRect(0, 0, size.width, size.height);
}

// Helper method for adding table cell into the attributed string

- (void)appendTableCellWithString:(NSString*)string table:(NSTextTable*)table textAlignment:(NSTextAlignment)textAlignment verticalAlignment:(NSTextBlockVerticalAlignment)verticalAlignment font:(NSFont*)font row:(int)row column:(int)column;
{
	CGSize stringSize = [string sizeWithAttributes:@{ NSFontAttributeName : font }];

	NSTextTableBlock* block = [[[NSTextTableBlock alloc] initWithTable:table startingRow:row rowSpan:1 startingColumn:column columnSpan:1] autorelease];

	if(column > 0)
		[block setContentWidth:stringSize.width type:NSTextBlockAbsoluteValueType];

	block.verticalAlignment = verticalAlignment;

	NSMutableParagraphStyle* paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setTextBlocks:@[ block ]];
	[paragraphStyle setAlignment:textAlignment];

	string = [string stringByAppendingString:@"\n"];

	NSMutableAttributedString* cellString = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
	[cellString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cellString length])];
	[cellString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [cellString length])];

	size.width += stringSize.width;
	if(size.height < stringSize.height)
		size.height = stringSize.height;

	[self appendAttributedString:cellString];
}

- (CGSize)size
{
	return size;
}

@end

@implementation NSMenuItem (FileIcon)

- (void)setIconForFile:(NSString*)path;
{
	NSImage* icon = nil;
    
	if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
		icon = [OakFileIconImage fileIconImageWithPath: path
                                                  size: NSMakeSize(16, 16)];
        
	}else if([path pathExtension])
    {
		icon = [[NSWorkspace sharedWorkspace] iconForFileType: [path pathExtension]];
        
	}else
    {
		icon = [[NSWorkspace sharedWorkspace] iconForFileType: NSFileTypeForHFSTypeCode(kUnknownFSObjectIcon)];
    }
    
	if(icon)
	{
		[icon setSize: NSMakeSize(16, 16)];
		[self setImage: icon];
	}
}

- (void)setKeyEquivalentCxxString: (NSString *)aKeyEquivalent
{
	if(!aKeyEquivalent)
	{
		[self setKeyEquivalent:@""];
		[self setKeyEquivalentModifierMask:0];
		return;
	}

	NSUInteger modifiers = 0;

    const char *keyEquivalentCString = [aKeyEquivalent UTF8String];
    
	NSUInteger i = 0;
	while(true)
	{
		if(i+1 >= [aKeyEquivalent length] || !strchr("$^~@#", keyEquivalentCString[i]))
			break;

		switch(keyEquivalentCString[i++])
		{
			case '$': modifiers |= NSShiftKeyMask;      break;
			case '^': modifiers |= NSControlKeyMask;    break;
			case '~': modifiers |= NSAlternateKeyMask;  break;
			case '@': modifiers |= NSCommandKeyMask;    break;
			case '#': modifiers |= NSNumericPadKeyMask; break;
		}
	}

	[self setKeyEquivalent: [aKeyEquivalent substringFromIndex: i]];
	[self setKeyEquivalentModifierMask: modifiers];
}

- (void)setTabTriggerCxxString: (NSString *)aTabTrigger
{
	if(!aTabTrigger)
		return;

	MenuMutableAttributedString* attributedTitle = [[[MenuMutableAttributedString alloc] init] autorelease];
	NSTextTable* table = [[[NSTextTable alloc] init] autorelease];
	[table setNumberOfColumns:2];

	NSFont* font = self.menu.font ?: [NSFont menuFontOfSize: 0];
	[attributedTitle appendTableCellWithString: self.title
                                         table: table
                                 textAlignment: NSLeftTextAlignment
                             verticalAlignment: NSTextBlockMiddleAlignment
                                          font: font
                                           row: 0
                                        column: 0];
    
	[attributedTitle appendTableCellWithString: [NSString stringWithFormat: @" %@⇥", aTabTrigger]
                                         table: table
                                 textAlignment: NSRightTextAlignment
                             verticalAlignment: font.pointSize >= 13 ? NSTextBlockBottomAlignment : NSTextBlockMiddleAlignment
                                          font: [NSFont menuBarFontOfSize: floor(font.pointSize * 0.85)]
                                           row: 0
                                        column: 1];
	NSString* plainTitle = self.title;
	self.attributedTitle = attributedTitle;
	self.title = plainTitle;
}

- (void)setModifiedState:(BOOL)flag
{
    NSImage* image = [NSImage imageNamed:@"NSMenuItemBullet"];
	if(image)
	{
		[self setMixedStateImage:image];
		[self setState:NSMixedState];
	}
}
@end
