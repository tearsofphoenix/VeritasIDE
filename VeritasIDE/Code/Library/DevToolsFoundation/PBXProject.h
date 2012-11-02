/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <DevToolsCore/PBXContainer.h>

#import "PBXChangeNotification-Protocol.h"
#import "PBXContainerItemChangeNotification-Protocol.h"
#import "XCCompatibilityChecking-Protocol.h"
#import "XCConfigurationInspectables-Protocol.h"

@class PBXBookmarkGroup, PBXBuildSettingsDictionary, PBXBuildStyle, PBXCodeSenseManager, PBXExecutable, PBXFileReference, PBXGroup, PBXLogOutputString, PBXProjectIndex, PBXTarget, XCArchiveFormat, XCBreakpointsBucket, XCBuildOperation, XCConfigurationList, XCFileSystemWatcher, XCRoots, XCSourceControlManager;

@interface PBXProject : PBXContainer <PBXChangeNotification, PBXContainerItemChangeNotification, XCCompatibilityChecking, XCConfigurationInspectables>
{
    struct {
        unsigned int readOnly:1;
        unsigned int wantsIndex:1;
        unsigned int dependencyGraphBearTrapping:1;
        unsigned int autosavingSuspended:1;
        unsigned int projectClosing:1;
        unsigned int projectClosed:1;
        unsigned int forceWriteToFileSystem:1;
        unsigned int RESERVED:25;
    } _pFlags;
    NSMutableDictionary *_attributes;
    NSUInteger _savedArchiveVersion;
    PBXFileReference *_projectFileRef;
    PBXFileReference *_userSettingsFileRef;
    NSMutableArray *_targets;
    PBXTarget *_activeTarget;
    NSMutableArray *_breakpoints;
    XCBreakpointsBucket *_breakpointsGroup;
    NSHashTable *_changedItems;
    int _changedItemMask;
    NSTimer *_autosaveTimer;
    BOOL _endOfEventSchedulePending;
    NSDate *_projectArchiveModTime;
    NSDate *_userSettingsModTime;
    NSString *_developmentRegion;
    NSMutableArray *_knownRegions;
    NSMutableArray *_knownPlatforms;
    NSString *_projectDirPath;
    NSMutableArray *_addToTargets;
    PBXGroup *_productRefGroup;
    PBXProjectIndex *_index;
    NSInteger _nIndexUsers;
    XCConfigurationList *_buildConfigurationList;
    PBXBuildSettingsDictionary *_buildSettings;
    PBXBuildSettingsDictionary *_userBuildSettings;
    PBXBuildSettingsDictionary *_projectOverridingBuildSettings;
    PBXBookmarkGroup *_userBookmarkGroup;
    NSMutableDictionary *_perUserProjectItems;
    NSMutableArray *_buildStyles;
    PBXBuildStyle *_activeBuildStyle;
    NSMutableArray *_executables;
    PBXExecutable *_activeExecutable;
    NSMapTable *_projectReferences;
    XCFileSystemWatcher *_fsWatcher;
    PBXLogOutputString *_upgradeLog;
    XCSourceControlManager *_sourceControlManager;
    XCBuildOperation *_mostRecentBuildOperation;
    BOOL _hasScannedForEncodings;
    NSString *_cachedStandardizedProjectDirectory;
    PBXCodeSenseManager *_codeSenseManager;
    NSMutableArray *_expressions;
    NSString *_activeArchitecture;
    NSString *_activeArchitecturePreference;
    NSString *_activeBuildAction;
    NSString *_activeBuildConfigurationName;
    NSString *_activeSDKPreference;
    NSMutableArray *_availableArchitectures;
    NSMutableArray *_availableBuildConfigurationNames;
    NSArray *_targetTemplates;
    NSMutableDictionary *_cachedPropExpContexts;
    NSMutableDictionary *_cachedInspectionInfoContexts;
    NSMutableDictionary *_ignoreBreakpointsInProjectsDict;
    NSSet *_currentFeatureUsage;
    XCArchiveFormat *_preferredProjectFormat;
    XCRoots *_roots;
    id <XCRemoteComputer> _activeDevice;
    id <XCRemoteComputer> _previousActiveDevice;
    id <XCRemoteComputer> _lastSimulatorDevice;
    id _lastSelectedDevice;
    int _currentArchivePriority;
    BOOL _shouldKilIBToolAgent;
}

+ (void)waitForSpeculativeCompileCompletionForFile:(id)arg1;
+ (void)endSpeculativeCompileOfFile:(id)arg1;
+ (void)beginSpeculativeCompileOfFile:(id)arg1;
+ (void)setRunloopModesForProjectItemChangedPerformer:(id)arg1;
+ (id)runloopModesForProjectItemChangedPerformer;
+ (void)_autosave:(id)arg1;
+ (BOOL)_projectIsOpen:(id)arg1;
+ (id)archivableUserRelationships;
+ (id)archivableUserAttributes;
+ (id)archivableRelationships;
+ (id)archivableAttributes;
+ (BOOL)copyProjectAtPath:(id)arg1 toPath:(id)arg2;
+ (id)archiveNameForKey:(id)arg1;
+ (void)setAutosavingEnabled:(BOOL)arg1;
+ (BOOL)autosavingEnabled;
+ (id)targetsInAllProjectsForFileReference:(id)arg1 justNative:(BOOL)arg2;
+ (id)setFromDeviceFamilyObject:(id)arg1;
+ (id)numberFromObject:(id)arg1;
+ (id)applicationwideIntermediatesDirectory;
+ (id)applicationwideProductDirectory;
+ (void)setApplicationwideIntermediatesDirectory:(id)arg1;
+ (void)setApplicationwideProductDirectory:(id)arg1;
+ (void)propagateSourceTreeDisplayNamesToUserDefaults;
+ (id)sourceTreeDisplayNamesDictionary;
+ (void)buildSettingsDictionary:(id)arg1 didSetValue:(id)arg2 withOperation:(int)arg3 forKeyPath:(id)arg4;
+ (void)_propagateAppPrefsBuildSettingsToUserDefaults;
+ (id)applicationPreferencesBuildSettings;
+ (id)environmentXcconfigFileBuildSettings;
+ (id)commandLineXcconfigFileBuildSettings;
+ (id)globalOverridingBuildSettings_asPropertyValues;
+ (id)globalOverridingBuildSettings;
+ (id)_formatForMissingPreferredProjectFormatAttribute;
+ (id)preferrableProjectFormats;
+ (BOOL)checkVersion:(NSUInteger)arg1 forPListUnarchiver:(id)arg2;
+ (id)unarchivingFormatForVersion:(NSUInteger)arg1 forPListUnarchiver:(id)arg2;
+ (id)projectWithFile:(id)arg1;
+ (id)projectWithFile:(id)arg1 errorHandler:(id)arg2;
+ (id)projectWithFile:(id)arg1 errorHandler:(id)arg2 readOnly:(BOOL)arg3;
+ (BOOL)shouldKeepOriginalReference:(id)arg1 usingOriginalObjectCounts:(id)arg2;
+ (id)projectWrapperPathForPath:(id)arg1;
+ (BOOL)_isAllowedToWriteToUserFile:(id)arg1 inWrapperAtPath:(id)arg2;
+ (BOOL)_isAllowedToWriteToProjectFile:(id)arg1 inWrapperAtPath:(id)arg2;
+ (BOOL)_isAllowedToWriteToFile:(id)arg1 inWrapperAtPath:(id)arg2;
+ (void)initialize;
+ (id)keyPathsForValuesAffectingPreferredFormatConflicts;
+ (id)_formatForArchiveVersion:(NSUInteger)arg1;
+ (id)_formatForIdentifier:(id)arg1;
+ (id)_nativeFormat;
+ (id)_xcode3_2Format;

+ (id)supportedProjectFormats;
+ (id)_projectFormatsByIdentifier;
+ (id)openProjects;
+ (id)defaultUserSettingsPathWithPath:(id)arg1;
+ (id)userSettingsPathWithPath:(id)arg1;
+ (id)projectFilePathWithPath:(id)arg1;
+ (id)knownProjectWrapperExtensions;
+ (BOOL)isProjectWrapperExtension:(id)arg1;
+ (id)projectWrapperExtension;
+ (id)_projectArchiveFormatSupportingFeatures:(id)arg1;
+ (id)allowedProjectArchiveVersions;
+ (id)defaultKnownPlatforms;
+ (id)defaultKnownRegions;
+ (id)appleScriptFileTypes;
+ (id)linkableFileTypes;
+ (id)rezzableFileTypes;
+ (id)sourceFileTypes;
+ (id)headerFileTypes;
+ (void)renamedFileAtPath:(id)arg1 to:(id)arg2 callbackTarget:(id)arg3 selector:(SEL)arg4 error:(id)arg5;
- (void)deviceRemove:(id)arg1;
- (void)deviceAdded:(id)arg1;
- (void)setActiveDevice:(id)arg1;
- (void)_resetActiveDevice:(id)arg1;
- (void)_devicesDidChange;
- (BOOL)isEqualToLastSelectedDevice:(id)arg1;
- (id)lastSelectedDevice;
- (id)defaultActiveDevice;
- (id)activeDevice;
- (void)cancelPendingActivities;
- (void)untouchFileAtPath:(id)arg1;
- (void)touchFileAtPath:(id)arg1;
- (void)fileMayHaveChangedAtPath:(id)arg1;
- (BOOL)_hasScannedForEncodings;
- (void)_setHasScannedForEncodings:(BOOL)arg1;
- (void)clearAllPerUserProjectItems;
- (void)removePerUserProjectItemForGUIDHexString:(id)arg1;
- (void)addPerUserProjectItem:(id)arg1;
- (id)perUserDictionaryObjectForGUIDHexString:(id)arg1;
- (id)perUserProjectItems;
- (void)_SDKRootDidChange:(id)arg1;
- (void)_indexingDefaultDisabled:(id)arg1;
- (void)_indexingDefaultEnabled:(id)arg1;
- (void)setShouldKilIBToolAgent:(BOOL)arg1;
- (id)indexDirectory;
- (void)stopIndexing;
- (BOOL)isIndexing;
- (BOOL)hasIndex;
- (void)rebuildIndex;
- (void)dropIndex;
- (void)beginIndexing;
- (id)projectIndex;
- (void)loadIndex;
- (BOOL)wantsIndex;
- (void)closeIndex;
- (void)openIndex;
- (BOOL)isAllowedToUpdateIndex;
- (id)codeSenseManager;
- (id)destinationPath:(id)arg1 forSourcePath:(id)arg2 ofType:(id)arg3 forFileManager:(id)arg4;
- (BOOL)installSourcesToPath:(id)arg1;
- (BOOL)isBeingBuilt;
- (void)setMostRecentBuildOperation:(id)arg1;
- (id)mostRecentBuildOperation;
- (id)allChangedItems;
- (int)changeMask;
- (void)_addChangeMask:(int)arg1;
- (BOOL)hasItemChangedWithMask:(int)arg1;
- (BOOL)hasItemChanged:(id)arg1;
- (void)willChange;
- (void)willChangeWithArchivePriority:(int)arg1;
- (void)item:(id)arg1 willChangeWithArchivePriority:(int)arg2;
- (void)_scheduleEndOfEventProcessing:(int)arg1;
- (void)_processEndOfEvent;
- (BOOL)forceWriteToFileSystem;
- (void)setForceWriteToFileSystem:(BOOL)arg1;
- (BOOL)autosavingSuspended;
- (void)setAutosavingSuspended:(BOOL)arg1;
- (void)_startAutoSaveTimer;
- (void)_endAutoSaveTimer;
- (id)suddenTerminationClientName;
- (void)removeBreakpoint:(id)arg1;
- (void)replaceBreakpointAtIndex:(NSInteger)arg1 withBreakpoint:(id)arg2;
- (void)insertBreakpoint:(id)arg1 atIndex:(NSInteger)arg2;
- (void)addBreakpoint:(id)arg1;
- (id)breakpointsForFilename:(id)arg1;
- (id)breakpointsForFileReference:(id)arg1;
- (id)breakpointsInProjectsForPath:(id)arg1;
- (id)breakpointsInProjects;
- (id)relativeFileReferenceForPath:(id)arg1;
- (void)setEnableBreakpoints:(BOOL)arg1 forProjectName:(id)arg2;
- (BOOL)breakpointsAreEnabledForProject:(id)arg1;
- (id)projectsWithBreakpointsForProjects:(id)arg1 visited:(id)arg2 filterIgnoredProjects:(BOOL)arg3;
- (id)_recursiveProjectsWithBreakpointsForProjects:(id)arg1 visited:(id)arg2 filterIgnoredProjects:(BOOL)arg3;
- (id)symbolicBreakpoints;
- (id)fileBreakpoints;
- (id)breakpointsGroup;
- (void)_setBreakpointsGroup:(id)arg1;
- (id)breakpoints;
- (id)breakpointsInReferencedProjects;
- (void)_setBreakpoints:(id)arg1;
- (void)removeExpressionString:(id)arg1;
- (void)addExpressionString:(id)arg1;
- (id)expressions;
- (void)appendSpotlightDescriptionToString:(id)arg1;
- (void)insertRootObject:(id)arg1 intoContainer:(id)arg2;
- (id)gidCommentForArchive;
- (void)_setProjectwideBuildSettings:(id)arg1;
- (id)_projectwideBuildSettings;
- (void)_setUserBuildSettings:(id)arg1;
- (void)_setBuildSettings:(id)arg1;
- (void)_setBuildConfigurationList:(id)arg1;
- (id)_projectReferences;
- (void)_setProjectReferences:(id)arg1;
- (void)_setExecutables:(id)arg1;
- (void)_setUserBookmarkGroup:(id)arg1;
- (BOOL)shouldArchiveAttributes;
- (BOOL)shouldArchiveIntermediatesDirectory;
- (BOOL)shouldArchiveProductDirectory;
- (BOOL)shouldArchiveUserBookmarkGroup;
- (void)_unarchiverDidFinishUnarchiving:(id)arg1;
- (void)awakeFromPListUnarchiver:(id)arg1;
- (void)_prepareForUnarchiving;
- (id)readFromPListUnarchiver:(id)arg1;
- (void)_setIntermediatesDirectory:(id)arg1;
- (void)_setProductDirectory:(id)arg1;
- (void)createDefaultBuildStylesIfNeeded;
- (void)createDefaultProjectSettingsConfigurationsIfNeeded;
- (BOOL)shouldArchiveActiveBuildStyle;
- (BOOL)shouldArchiveBuildStyles;
- (BOOL)shouldArchiveBuildSettings;
- (BOOL)shouldArchivePerUserProjectItems;
- (BOOL)shouldArchivePerUserDictionary;
- (BOOL)shouldArchiveKnownPlatforms;
- (BOOL)shouldArchiveKnownRegions;
- (BOOL)shouldArchiveDevelopmentRegion;
- (BOOL)shouldArchiveExecutables;
- (id)upgradeLog;
- (void)addPlatform:(id)arg1;
- (id)knownPlatforms;
- (void)addRegion:(id)arg1;
- (id)knownRegions;
- (void)setDevelopmentRegion:(id)arg1;
- (id)developmentRegion;
- (void)setProductReferenceGroup:(id)arg1;
- (id)productReferenceGroup;
- (id)fileSystemWatcher;
- (id)referencedProjects;
- (void)removeProjectReference:(id)arg1;
- (id)addProjectReferenceForProject:(id)arg1;
- (void)addProjectReference:(id)arg1;
- (id)productsForProject:(id)arg1;
- (id)productsForProjectReference:(id)arg1;
- (id)projectReferenceForProject:(id)arg1;
- (id)projectReferenceForPath:(id)arg1;
- (id)projectReferences;
- (id)relevantToolSpecifications;
- (id)relevantToolSpecificationsForConfigurationsNamed:(id)arg1;
- (id)relevantToolSpecificationsForConfigurationNamed:(id)arg1;
- (void)removeExecutable:(id)arg1;
- (BOOL)canRemoveExecutable:(id)arg1 denialReason:(id *)arg2;
- (void)addExecutable:(id)arg1;
- (void)insertExecutables:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)executableNamed:(id)arg1;
- (id)executables;
- (void)setExecutables:(id)arg1;
- (id)activeExecutable;
- (void)setActiveExecutable:(id)arg1;
- (id)_buildConfigurationOwnersInProject;
- (void)updateDefaultConfigurationVisibility:(BOOL)arg1;
- (void)updateDefaultConfigurationToConfigurationNamed:(id)arg1;
- (void)moveBuildConfigurationsAtIndexes:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)renameBuildConfigurationNamed:(id)arg1 to:(id)arg2;
- (id)duplicateBuildConfigurationNamed:(id)arg1;
- (void)deleteBuildConfigurationNamed:(id)arg1;
- (void)_didChangeConfigurationNames;
- (void)_willChangeConfigurationNames;
- (id)defaultConfigurationName;
- (void)setDefaultConfigurationName:(id)arg1;
- (id)possibleActiveBuildConfigurationNames;
- (id)availableBuildConfigurationNames;
- (void)setActiveBuildConfigurationName:(id)arg1;
- (id)_activeBuildConfigurationName;
- (id)activeBuildConfigurationName;
- (id)activeBuildAction;
- (void)_validArchsMayHaveChanged:(id)arg1;
- (id)availableArchitectures;
- (void)setActiveArchitecturePreference:(id)arg1;
- (id)activeArchitecturePreference;
- (void)setActiveArchitecture:(id)arg1;
- (id)activeArchitecture;
- (void)setActiveBuildStyle:(id)arg1;
- (id)_activeBuildStyle;
- (id)activeBuildStyle;
- (void)_setBuildStyles:(id)arg1;
- (void)removeBuildStyle:(id)arg1;
- (void)addBuildStyle:(id)arg1;
- (void)insertBuildStyles:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)buildStyleWithGlobalID:(id)arg1;
- (id)buildStyleNamed:(id)arg1;
- (id)buildStyles;
- (id)targetsForFileReference:(id)arg1 justNative:(BOOL)arg2;
- (id)targetsAcceptingAnyFileTypes;
- (id)targetsAcceptingFileType:(id)arg1;
- (void)setAddToTargets:(id)arg1;
- (id)addToTargets;
- (void)setActiveTargetAndSetActiveExecutableIfAppropriate:(id)arg1;
- (void)setActiveTarget:(id)arg1;
- (id)activeTarget;
- (id)allTargetsInDependencyOrder;
- (void)removeTarget:(id)arg1;
- (void)addTarget:(id)arg1;
- (void)insertTargets:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)targetWithGlobalID:(id)arg1;
- (id)targetNamed:(id)arg1;
- (id)targets;
- (id)targetTemplates;
- (void)setActiveSDKPackage:(id)arg1;
- (id)activeSDKPackage;
- (id)baseSDKIdentifierForTarget:(id)arg1;
- (id)baseSDKIdentifier;
- (id)baseSDKForTarget:(id)arg1;
- (id)baseSDK;
- (void)setActiveSDKPreference:(id)arg1;
- (id)activeSDKPreference;
- (id)validSDKsForTarget:(id)arg1;
- (id)allSDKsPlusTargetSDKs:(id)arg1;
- (id)validProjectLevelSDKs;
- (void)setProjectSDKNameOrPath:(id)arg1 forConfiguration:(id)arg2;
- (void)setProjectSDKNameOrPathForAllConfigurations:(id)arg1;
- (void)setProjectSDK:(id)arg1 forConfiguration:(id)arg2;
- (void)setProjectSDKForAllConfigurations:(id)arg1;
- (id)projectSDKForConfiguration:(id)arg1;
- (id)projectSDKSettingForConfiguration:(id)arg1;
- (id)projectSDKForAllConfigurationsAndTargetsHasMultiple:(char *)arg1;
- (id)projectSDKSettingForAllConfigurationsHasMultiple:(char *)arg1;
- (id)projectSDKForAllConfigurationsHasMultiple:(char *)arg1;
- (id)userBookmarkGroup;
- (BOOL)hasPerProjectIntermediatesDirectory;
- (BOOL)hasPerProjectProductDirectory;
- (id)perProjectIntermediatesDirectory;
- (id)perProjectProductDirectory;
- (void)setPerProjectIntermediatesDirectory:(id)arg1;
- (void)setPerProjectProductDirectory:(id)arg1;
- (id)intermediatesDirectory;
- (id)intermediatesDirectoryForConfigurationNamed:(id)arg1;
- (id)productDirectory;
- (id)productDirectoryForConfigurationNamed:(id)arg1;
- (id)intermediatesLocation;
- (id)intermediatesLocationForConfigurationNamed:(id)arg1;
- (id)builtProductsLocation;
- (id)builtProductsLocationForConfigurationNamed:(id)arg1;
- (id)fallbackIntermediatesDirectoryForConfigurationNamed:(id)arg1;
- (id)fallbackProductDirectoryForConfigurationNamed:(id)arg1;
- (void)discardCachedContextsForConfigurationNamed:(id)arg1;
- (void)discardAllCachedContexts;
- (int)propertyDefinitionLevel;
- (id)cachedPropertyInfoContext;
- (id)cachedPropertyInfoContextForConfigurationNamed:(id)arg1;
- (id)createPropertyInfoContextWithBuildAction:(id)arg1 configurationName:(id)arg2;
- (void)discardCachedConfigurationInspectionContextForConfigurationNamed:(id)arg1;
- (void)discardAllCachedConfigurationInspectionContexts;
- (id)configurationInspectionContextForConfigurationNamed:(id)arg1;
- (id)absoluteExpandedPathForString:(id)arg1;
- (id)absoluteExpandedPathForString:(id)arg1 forConfigurationNamed:(id)arg2;
- (id)expandedValueForString:(id)arg1;
- (id)expandedValueForString:(id)arg1 forConfigurationNamed:(id)arg2;
- (void)discardCachedPropertyExpansionContextForConfigurationNamed:(id)arg1;
- (void)discardAllCachedPropertyExpansionContexts;
- (id)cachedPropertyExpansionContextForConfigurationNamed:(id)arg1;
- (id)createPropertyExpansionContextForConfigurationNamed:(id)arg1;
- (id)projectDirectory;
- (BOOL)buildSettingsDictionaryShouldExtractQuotedBuildSettingsWhenSplitting:(id)arg1;
- (id)dynamicallyComputedProjectwideBuildSettingsForConfigurationNamed:(id)arg1;
- (void)noteBuildSettingsDidChangeForConfigurationNamed:(id)arg1;
- (id)buildSettingsDictionary:(id)arg1 willSetValue:(id)arg2 withOperation:(int)arg3 forKeyPath:(id)arg4;
- (id)userBuildSettings;
- (id)projectOverridingBuildSettings;
- (id)buildConfigurationList;
- (id)name;
- (id)path;
- (void)setPath:(id)arg1;
- (BOOL)writeToFileSystemProjectFile:(BOOL)arg1 userFile:(BOOL)arg2 checkNeedsRevert:(BOOL)arg3;
- (BOOL)_writeToFileSystem;
- (BOOL)_writeToFileSystemProjectFile:(BOOL)arg1 userFile:(BOOL)arg2 checkNeedsRevert:(BOOL)arg3;
- (BOOL)writeToFile:(id)arg1 projectFile:(BOOL)arg2 userFile:(BOOL)arg3 outResultNotification:(id *)arg4;
- (BOOL)needsRevert;
- (void)_setCurrentArchivePriority:(int)arg1;
- (int)_currentArchivePriority;
- (BOOL)needsArchive;
- (id)userSettingsFileRef;
- (id)userSettingsPath;
- (id)projectFileRef;
- (id)projectRootPath;
- (id)projectRootPaths;
- (id)_projectRoot;
- (id)_projectRoots;
- (void)_setProjectRoot:(id)arg1;
- (id)roots;
- (void)setProjectRoots:(id)arg1;
- (id)projectRoots;
- (id)projectFilePath;
- (void)findFeaturesInUseAndAddToSet:(id)arg1 usingPathPrefix:(id)arg2;
- (void)_setCompatibilityVersion:(id)arg1;
- (id)_compatibilityVersion;
- (id)savedProjectFormat;
- (void)setPreferredProjectFormat:(id)arg1;
- (id)preferredProjectFormat;
- (void)_updateCurrentFeatureUsage;
- (id)_featuresInUse;
- (void)_setCurrentFeatureUsage:(id)arg1;
- (id)_currentFeatureUsage;
- (id)preferredFormatConflicts;
- (void)appDefaultForSCMDidChange:(id)arg1;
- (id)scmInfo;
- (id)sourceControlManager;
- (void)setSourceControlManager:(id)arg1;
- (id)perUserDictionary;
- (void)setBuildIndependentTargetsInParallel:(BOOL)arg1;
- (BOOL)buildIndependentTargetsInParallel;
- (id)attributes;
- (BOOL)allowsEditingOfChildren;
- (BOOL)isClosed;
- (void)finalize;
- (void)dealloc;
- (void)close;
- (void)removeReference:(id)arg1;
- (id)currentFormatForPListArchiver:(id)arg1;
- (BOOL)_shouldUpgradeSavedArchiveVersion;
- (void)_setSavedArchiveVersion:(NSUInteger)arg1;
- (NSUInteger)savedArchiveVersion;
- (BOOL)canWriteToAuxiliaryProjectFileWithName:(id)arg1;
- (BOOL)canWriteToUserFile;
- (BOOL)canWriteToProjectFile;
- (BOOL)mayBeUnwritableProject;
- (void)_setReadOnly:(BOOL)arg1;
- (BOOL)isReadOnly;
- (void)_initializeNotifications;
- (id)init;
- (void)buildConfiguration:(id)arg1 willBeRemovedFromTarget:(id)arg2;
- (void)buildConfiguration:(id)arg1 wasAddedToTarget:(id)arg2;
- (void)buildPhase:(id)arg1 willBeRemovedFromTarget:(id)arg2;
- (void)buildPhase:(id)arg1 wasAddedToTarget:(id)arg2;
- (void)executableWillBeRemoved:(id)arg1;
- (void)executableWasAdded:(id)arg1;
- (void)buildStyleWillBeRemoved:(id)arg1;
- (void)buildStyleWasAdded:(id)arg1;
- (void)group:(id)arg1 willAddChild:(id)arg2;
- (void)buildFileDidReorder:(id)arg1 oldIndex:(NSInteger)arg2 newIndex:(NSInteger)arg3;
- (void)buildFileWillBeRemoved:(id)arg1;
- (void)buildFileWasAdded:(id)arg1;
- (void)targetWillBeRemoved:(id)arg1;
- (void)targetWasAdded:(id)arg1;
- (void)breakpointWillBeDeleted:(id)arg1;
- (void)breakpointWasAdded:(id)arg1;
- (void)referenceWillBeRemoved:(id)arg1;
- (void)referenceWillChange:(id)arg1;
- (void)referenceWasRenamed:(id)arg1 oldAbsolutePath:(id)arg2;
- (void)referenceWasAdded:(id)arg1;
- (void)appendUserSettingsDictionariesTo:(id)arg1 defaultSettingsDictionariesTo:(id)arg2;
- (void)appendUserSettingsDictionariesTo:(id)arg1 defaultSettingsDictionariesTo:(id)arg2 forBuildConfigurationNamed:(id)arg3;
- (id)flattenedBuildSettingsDictionaryForShowingInUserInterface;
- (id)flattenedBuildSettingsDictionaryForShowingInUserInterfaceWithBuildConfigurationNamed:(id)arg1;
- (id)buildSettingDictionariesForShowingInUserInterface;
- (id)buildSettingDictionariesForShowingInUserInterfaceWithBuildConfigurationNamed:(id)arg1;
- (id)nextOrderedSymbol;
- (id)symbolWithName:(id)arg1;
- (id)rootClasses;
- (id)handleCommitScriptCommand:(id)arg1;
- (id)handleUpdateScriptCommand:(id)arg1;
- (id)handleRefreshScriptCommand:(id)arg1;
- (void)moveObject:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)removeFromTargetsAtIndex:(NSUInteger)arg1;
- (void)replaceInTargets:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInTargets:(id)arg1;
- (void)insertInTargets:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)_postInsertTargetSetupForTarget:(id)arg1;
- (id)valueInTargetsAtIndex:(NSUInteger)arg1;
- (void)removeFromExecutablesAtIndex:(NSUInteger)arg1;
- (void)replaceInExecutables:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInExecutables:(id)arg1;
- (void)insertInExecutables:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInExecutablesAtIndex:(NSUInteger)arg1;
- (void)removeFromBuildConfigurationTypesAtIndex:(NSUInteger)arg1;
- (void)insertInBuildConfigurationTypes:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInBuildConfigurationTypes:(id)arg1;
- (id)valueInBuildConfigurationTypesAtIndex:(NSUInteger)arg1;
- (id)buildConfigurationTypes;
- (void)setDefaultBuildConfigurationType:(id)arg1;
- (id)defaultBuildConfigurationType;
- (void)setActiveBuildConfigurationType:(id)arg1;
- (id)activeBuildConfigurationType;
- (id)valueInBuildConfigurationsAtIndex:(NSUInteger)arg1;
- (id)buildConfigurations;
- (void)removeFromBuildStylesAtIndex:(NSUInteger)arg1;
- (void)replaceInBuildStyles:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInBuildStyles:(id)arg1;
- (void)insertInBuildStyles:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInBuildStylesAtIndex:(NSUInteger)arg1;
- (void)removeFromSymbolicBreakpointsAtIndex:(NSUInteger)arg1;
- (void)replaceInSymbolicBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInSymbolicBreakpoints:(id)arg1;
- (void)insertInSymbolicBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInSymbolicBreakpointsAtIndex:(NSUInteger)arg1;
- (void)removeFromFileBreakpointsAtIndex:(NSUInteger)arg1;
- (void)replaceInFileBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInFileBreakpoints:(id)arg1;
- (void)insertInFileBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInFileBreakpointsAtIndex:(NSUInteger)arg1;
- (void)removeFromBreakpointsAtIndex:(NSUInteger)arg1;
- (void)replaceInBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInBreakpoints:(id)arg1;
- (void)insertInBreakpoints:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInBreakpointsAtIndex:(NSUInteger)arg1;
- (void)removeFromTextBookmarksAtIndex:(NSUInteger)arg1;
- (void)replaceInTextBookmarks:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInTextBookmarks:(id)arg1;
- (void)insertInTextBookmarks:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInTextBookmarksAtIndex:(NSUInteger)arg1;
- (id)textBookmarks;
- (void)removeFromBookmarksAtIndex:(NSUInteger)arg1;
- (void)replaceInBookmarks:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInBookmarks:(id)arg1;
- (void)insertInBookmarks:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInBookmarksAtIndex:(NSUInteger)arg1;
- (id)bookmarks;
- (void)setActiveSDKCanonicalName:(id)arg1;
- (id)activeSDKCanonicalName;
- (void)setOrganizationName:(id)arg1;
- (id)organizationName;
- (id)objectSpecifier;
- (id)compilationUnitForFilePath:(id)arg1 andDependentFilePaths:(id)arg2;
- (id)allCompilationUnits;
- (id)compilationUnitsForFilePaths:(id)arg1 allowOnlyObjectiveC:(BOOL)arg2;
- (id)compilationUnitForFilePath:(id)arg1;
- (id)buildFilePathsAndSettingsForCompilationUnits:(id)arg1;
- (BOOL)isFilePathObjCCompilationUnit:(id)arg1 alsoCheckForC:(BOOL)arg2;
- (BOOL)doesFilePath:(id)arg1 haveSimpleFileType:(id)arg2;
- (id)_targetsWithActiveTargetFirst;
- (void)removeSCMFileRunLoopMode:(id)arg1;
- (void)addSCMFileRunLoopMode:(id)arg1;
- (void)renameFileAtPath:(id)arg1 to:(id)arg2 callbackTarget:(id)arg3 selector:(SEL)arg4;
- (BOOL)_isProjectFileUnderSCM;
- (BOOL)canRenameFileAtPath:(id)arg1 to:(id)arg2 error:(id *)arg3;
- (id)preflightRenameProject;

@end

