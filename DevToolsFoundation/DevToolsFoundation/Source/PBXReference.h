/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <DevToolsCore/PBXContainerItem.h>

@class NSHashTable, NSMutableDictionary, NSString, PBXContainer, PBXGroup, PBXTarget, XCFileSystemNode, XCSCMInfo;

@interface PBXReference : PBXContainerItem
{
    NSString *_name;
    NSString *_path;
    NSString *_sourceTree;
    unsigned int _deallocating:1;
    unsigned int _didRegisterForNotifications:1;
    unsigned int _RESERVED_REF:30;
    NSMutableDictionary *_properties;
    PBXGroup *_group;
    PBXContainer *_container;
    PBXTarget *_producingTarget;
    NSString *_absolutePath;
    NSString *_absoluteDirectory;
    NSString *_resolvedAbsolutePath;
    NSString *_resolvedAbsoluteDirectory;
    NSString *_unexpandedFullPath;
    XCFileSystemNode *_fileSystemNode;
    NSHashTable *_buildFiles;
    XCSCMInfo *_scmInfo;
}

+ (id)archivableAttributes;
+ (id)archiveNameForKey:(id)arg1;
+ (Class)_referenceClassInList:(id)arg1 representingFileAtPath:(id)arg2 ofType:(id)arg3;
+ (id)allGroupsForGroup:(id)arg1;
- (void)pruneReferencesBySendingBooleanSelector:(SEL)arg1 toObject:(id)arg2 withContext:(void *)arg3;
- (NSInteger)compareType:(id)arg1;
- (NSInteger)compareName:(id)arg1;
- (NSUInteger)assignFileEncoding:(NSUInteger)arg1 onlyIfUnspecified:(BOOL)arg2;
- (BOOL)hasUnspecifiedFileEncodings;
- (id)referencesForBuilding;
- (BOOL)allowsRemovalFromDisk;
- (void)scmInfoChanged;
- (void)scmChildrenChanged;
- (void)childSCMInfoChanged:(id)arg1;
- (id)scmInfo;
- (void)setSCMInfo:(id)arg1;
- (id)createSCMInfoWithSandboxEntry:(id)arg1;
- (id)innerLongDescriptionWithIndentLevel:(NSUInteger)arg1;
- (id)innerDescription;
- (int)changeMask;
- (void)_setSourceTree:(id)arg1;
- (void)_setReferenceType:(int)arg1;
- (int)_referenceType;
- (BOOL)shouldArchiveReferenceType;
- (void)_setPath:(id)arg1;
- (BOOL)shouldArchiveName;
- (BOOL)shouldArchivePath;
- (id)gidCommentForArchive;
- (void)awakeFromPListUnarchiver:(id)arg1;
- (id)readFromPListUnarchiver:(id)arg1;
- (id)_path;
- (id)_sourceTree;
- (BOOL)_unarchivingShouldTranslateToUnitTestFrameworkReference;
- (BOOL)_archivingShouldTranslateFromUnitTestFrameworkReference;
- (BOOL)isCurrentVersion;
- (BOOL)isVersion;
- (BOOL)isVersionGroup;
- (id)regionVariantName;
- (BOOL)isRegionVariant;
- (BOOL)isVariant;
- (BOOL)isVariantGroup;
- (id)destinationGroupForFilenames:(id)arg1;
- (id)destinationGroupForInsertion;
- (BOOL)isAncestorOfItem:(id)arg1;
- (BOOL)isGroup;
- (BOOL)isLeaf;
- (void)validateChildren;
- (id)children;
- (BOOL)shouldArchiveIncludeInIndex;
- (void)setIncludeInIndex:(NSInteger)arg1;
- (BOOL)canSetIncludeInIndex;
- (BOOL)includeInIndex;
- (BOOL)shouldArchiveWrapsLines;
- (void)setWrapsLines:(NSInteger)arg1;
- (BOOL)wrapsLines;
- (BOOL)shouldArchiveUsesTabs;
- (void)setUsesTabs:(NSInteger)arg1;
- (BOOL)usesTabs;
- (BOOL)shouldArchiveIndentWidth;
- (void)setIndentWidth:(NSInteger)arg1;
- (NSInteger)indentWidth;
- (BOOL)shouldArchiveTabWidth;
- (void)setTabWidth:(NSInteger)arg1;
- (NSInteger)tabWidth;
- (BOOL)shouldArchiveFileEncoding;
- (void)setFileEncoding:(NSUInteger)arg1;
- (NSUInteger)fileEncoding;
- (BOOL)shouldArchiveLineEnding;
- (void)setLineEnding:(int)arg1;
- (int)lineEnding;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
- (BOOL)overridesPropertyForKey:(id)arg1;
- (id)propertyForKey:(id)arg1;
- (id)propertyForKey:(id)arg1 searchParent:(BOOL)arg2;
- (BOOL)userCanSetExplicitFileType;
- (id)fileProperties;
- (id)fileType;
- (void)invalidateAbsolutePathCache;
- (BOOL)changeSourceTree:(id)arg1;
- (void)setSourceTree:(id)arg1;
- (BOOL)moveToNewPath:(id)arg1;
- (BOOL)copyToNewPath:(id)arg1;
- (BOOL)setPath:(id)arg1;
- (void)setPath:(id)arg1 andSourceTree:(id)arg2;
- (void)_pathForSourceTreeDidChange:(id)arg1;
- (BOOL)fileExists;
- (id)unexpandedAbsolutePath;
- (id)absolutePathForDisplay;
- (id)developerDirRelativePath;
- (id)buildProductRelativePath;
- (id)groupRelativePath;
- (id)projectRelativePath;
- (id)resolvedAbsoluteDirectory;
- (id)absoluteDirectory;
- (id)fileSystemNode;
- (id)resolvedAbsolutePath;
- (id)absolutePath;
- (id)absolutePathForConfigurationNamed:(id)arg1;
- (id)path;
- (id)sourceTree;
- (id)_evaluatedPathForSourceTree:(id)arg1 appendPathWhenExpanded:(BOOL)arg2;
- (id)_evaluatedPathForSourceTree:(id)arg1 appendPathWhenExpanded:(BOOL)arg2 forConfigurationNamed:(id)arg3;
- (BOOL)ensureHasDefaultReference;
- (id)defaultReference;
- (id)groupTreeDisplayName;
- (BOOL)canSetName;
- (BOOL)setName:(id)arg1 syncDisk:(BOOL)arg2;
- (BOOL)_doFileSystemCopyTo:(id)arg1 deleteOriginal:(BOOL)arg2;
- (BOOL)_doFileSystemCopyFrom:(id)arg1 to:(id)arg2 deleteOriginal:(BOOL)arg3;
- (void)setName:(id)arg1;
- (id)name;
- (BOOL)allowsEditing;
- (id)absoluteExpandedPathForString:(id)arg1;
- (id)absoluteExpandedPathForString:(id)arg1 forConfigurationNamed:(id)arg2;
- (id)expandedValueForString:(id)arg1;
- (id)expandedValueForString:(id)arg1 forConfigurationNamed:(id)arg2;
- (void)fileDidMoveFromPath:(id)arg1;
- (id)presumedBuildConfigurationName;
- (BOOL)isProductReference;
- (id)includingTargets;
- (id)producingTarget;
- (void)setProducingTarget:(id)arg1;
- (BOOL)deleteFromProjectAndDisk:(BOOL)arg1;
- (void)deleteFromDisk;
- (void)removeFromGroup;
- (void)setGroup:(id)arg1;
- (id)group;
- (void)setContainer:(id)arg1;
- (id)container;
- (void)_notifyRegisteredBuildFilesWillDealloc;
- (id)registeredBuildFiles;
- (void)unregisterBuildFile:(id)arg1;
- (void)registerBuildFile:(id)arg1;
- (void)finalize;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)arg1 getUnretainedObjectMappings:(id *)arg2;
- (id)initWithName:(id)arg1 path:(id)arg2 referenceType:(int)arg3;
- (id)init;
- (id)initWithPath:(id)arg1;
- (id)initWithName:(id)arg1;
- (id)initWithName:(id)arg1 path:(id)arg2;
- (id)initWithName:(id)arg1 path:(id)arg2 sourceTree:(id)arg3 fileType:(id)arg4 extraFileProperties:(id)arg5;
- (id)initWithName:(id)arg1 path:(id)arg2 sourceTree:(id)arg3;
- (BOOL)didRegisterForNotifications;
- (void)removeNotifications;
- (void)addNotifications;
- (void)flattenItemsIntoArray:(id)arg1;
- (void)addUnexpandedFullPathToArray:(id)arg1;
- (id)absolutePathForExpansionContext:(id)arg1;
- (id)unexpandedFullPath;
- (void)setAppleScriptFileEncoding:(unsigned int)arg1;
- (unsigned int)appleScriptFileEncoding;
- (void)setAppleScriptReferenceType:(unsigned int)arg1;
- (unsigned int)appleScriptReferenceType;
- (void)setAppleScriptLineEnding:(unsigned int)arg1;
- (unsigned int)appleScriptLineEnding;
- (void)handleRemoveCommand:(id)arg1;
- (void)handleAddCommand:(id)arg1;
- (id)valueInFileReferencesAtIndex:(NSUInteger)arg1;
- (id)valueInGroupsAtIndex:(NSUInteger)arg1;
- (id)appleScriptEntireContents;
- (id)appleScriptContents;
- (id)fileReferences;
- (id)groups;
- (id)allFileReferencesForGroup:(id)arg1;
- (id)allReferencesForGroup:(id)arg1;
- (id)itemsInArray:(id)arg1 withClass:(Class)arg2;
- (id)objectSpecifier;
- (id)objectSpecifierForKey:(id)arg1 withAlternateKey:(id)arg2;
- (void)flattenItemsIntoHeaderFileEnumeratorArray:(id)arg1;
- (void)flattenItemsIntoRezSearchPathFileEnumeratorArray:(id)arg1;

@end
