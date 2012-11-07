
@interface NSMenuItem (FileIcon)

- (void)setIconForFile:(NSString*)path;

- (void)setKeyEquivalentCxxString:(NSString *)aKeyEquivalent;

- (void)setTabTriggerCxxString: (NSString *)aTabTrigger;

- (void)setModifiedState:(BOOL)flag;

@end

