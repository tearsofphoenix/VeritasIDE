#import "OakSavePanel.h"
#import "OakEncodingPopUpButton.h"
#import "NSSavePanel+Additions.h"
#import <OakFoundation/OakFoundation.h>


#import "OakFileEncodingType.h"

@interface OakEncodingSaveOptionsViewController : NSViewController
{
	IBOutlet OakEncodingPopUpButton* encodingPopUpButton;

}

@property (nonatomic, retain) NSString* lineEndings;
@property (nonatomic, retain) NSString* encoding;
@property (nonatomic, assign) BOOL useByteOrderMark;
@property (nonatomic, readonly) BOOL canUseByteOrderMark;
@property (nonatomic, readonly) OakFileEncodingType * encodingOptions;
@end

@implementation OakEncodingSaveOptionsViewController
@synthesize encodingOptions;

+ (NSSet*)keyPathsForValuesAffectingCanUseByteOrderMark { return [NSSet setWithObject:@"encoding"]; }
+ (NSSet*)keyPathsForValuesAffectingUseByteOrderMark    { return [NSSet setWithObject:@"encoding"]; }

+ (void)initialize
{
	[OakStringListTransformer createTransformerWithName:@"OakLineEndingsTransformer" andObjectsArray:@[ @"\n", @"\r", @"\r\n" ]];
	[OakStringListTransformer createTransformerWithName:@"OakLineEndingsListTransformer" andObjectsArray:@[ @"\n", @"\r", @"\r\n" ]];
}

- (id)initWithEncodingOptions:(OakFileEncodingType *)someEncodingOptions
{
	if(self = [super initWithNibName:@"EncodingSaveOptions" bundle:[NSBundle bundleForClass:[self class]]])
		encodingOptions = someEncodingOptions;
	return self;
}

- (void)dealloc
{
	[self unbind:@"encoding"];
	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	encodingPopUpButton.encoding = self.encoding;
	[self bind:@"encoding" toObject:encodingPopUpButton withKeyPath:@"encoding" options:nil];
}

- (BOOL)canUseByteOrderMark
{
    return supports_byte_order_mark([encodingOptions charsetName]);
}

- (NSString*)lineEndings
{
    return [encodingOptions newLines];
}

- (NSString*)encoding
{
    return [encodingOptions charsetName];
}

- (BOOL)useByteOrderMark
{
    return [encodingOptions byteOrderMarkSupported];
}

- (void)setLineEndings:(NSString*)newLineEndings
{
    [encodingOptions setNewLines: newLineEndings];
}

- (void)setEncoding:(NSString*)newEncoding
{
    [encodingOptions setCharsetName: newEncoding];
}

- (void)setUseByteOrderMark: (BOOL)newUseByteOrderMark
{
    [encodingOptions setByteOrderMarkSupported: newUseByteOrderMark];
}

@end

@implementation OakSavePanel

- (id)initWithPath: (NSString*)aPathSuggestion
         directory: (NSString*)aDirectorySuggestion
         fowWindow: (NSWindow*)aWindow
          delegate: (id)aDelegate
          encoding: (OakFileEncodingType *)encoding
{
	if((self = [super init]))
	{
		optionsViewController = [[OakEncodingSaveOptionsViewController alloc] initWithEncodingOptions:encoding];
		if(!optionsViewController)
		{
			[self release];
			return nil;
		}

		[[aWindow attachedSheet] orderOut:self]; // incase there already is a sheet showing (like “Do you want to save?”)

		NSSavePanel* savePanel = [NSSavePanel savePanel];
		[savePanel setTreatsFilePackagesAsDirectories:YES];
		if(aDirectorySuggestion)
			[savePanel setDirectoryURL:[NSURL fileURLWithPath:aDirectorySuggestion]];
		[savePanel setNameFieldStringValue:[aPathSuggestion lastPathComponent]];
		[savePanel setAccessoryView:optionsViewController.view];
		[savePanel beginSheetModalForWindow:aWindow completionHandler:^(NSInteger result) {
			NSString* path = result == NSOKButton ? [[savePanel.URL filePathURL] path] : nil;
			[aDelegate savePanelDidEnd:self path:path encoding:optionsViewController.encodingOptions];
			[self release];
		}];
		[savePanel deselectExtension];
	}
	return self;
}

- (void)dealloc
{
	[optionsViewController release];
	[super dealloc];
}

+ (void)showWithPath:(NSString*)aPathSuggestion directory:(NSString*)aDirectorySuggestion fowWindow:(NSWindow*)aWindow delegate:(id)aDelegate encoding:(OakFileEncodingType *)encoding
{
	[[OakSavePanel alloc] initWithPath:aPathSuggestion directory:aDirectorySuggestion fowWindow:aWindow delegate:aDelegate encoding:encoding];
}
@end
