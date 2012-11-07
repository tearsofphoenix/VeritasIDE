
@class OakFileEncodingType;

@class OakEncodingSaveOptionsViewController;

@interface OakSavePanel : NSObject
{
	OakEncodingSaveOptionsViewController* optionsViewController;
}

+ (void)showWithPath: (NSString*)aPathSuggestion
           directory: (NSString*)aDirectorySuggestion
           fowWindow: (NSWindow*)aWindow
            delegate: (id)aDelegate
            encoding: (OakFileEncodingType *)encoding;
@end

@interface NSObject (OakSavePanelDelegate)

- (void)savePanelDidEnd: (OakSavePanel*)sheet
                   path: (NSString*)aPath
               encoding: (OakFileEncodingType *)encoding;

@end
