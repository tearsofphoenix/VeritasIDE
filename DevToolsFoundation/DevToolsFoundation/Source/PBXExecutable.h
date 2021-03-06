/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <DevToolsCore/PBXProjectItem.h>

@class NSArray, NSMutableArray, NSMutableDictionary, NSString, PBXFileReference, PBXFileType, PBXProject, PBXTarget;

@interface PBXExecutable : PBXProjectItem
{
    NSString *_name;
    PBXProject *_project;
    PBXTarget *_target;
    PBXFileReference *_launchableReference;
    PBXFileType *_launchableFileType;
    BOOL _knowsLaunchability;
    BOOL _isLaunchable;
    NSArray *_shlibInfoDictList;
    NSMutableArray *_shlibInfoDictList_v2;
    NSString *_remoteInstallationPath;
    NSMutableArray *_argumentEntries;
    NSMutableArray *_environmentEntries;
    NSMutableArray *_sourceDirectories;
    NSString *_dylibVariantSuffix;
    BOOL _enableDebugStr;
    NSString *_startupPath;
    int _startupPathType;
    BOOL _startupPathTypeInitialized;
    NSMutableDictionary *_configStateDict;
    NSMutableDictionary *_configsDict;
    BOOL _customDataFormattersEnabled;
    BOOL _showTypeColumn;
    BOOL _dataTipCustomDataFormattersEnabled;
    BOOL _dataTipShowTypeColumn;
    short _dataTipSortType;
    NSInteger _disassemblyDisplayState;
    BOOL _libgmallocEnabled;
    id _execLocation;
    NSString *_debuggerPlugin;
    NSMutableDictionary *_savedGlobals;
    NSInteger _executableSystemSymbolLevel;
    NSInteger _executableUserSymbolLevel;
    BOOL _autoAttachOnCrash;
    NSMutableDictionary *_variableFormatDictionary;
    BOOL _breakpointsEnabled;
}

+ (NSInteger)symbolsWhenToLoadFromShlibInfoDict:(id)arg1;
+ (NSInteger)symbolsLevelFromShlibInfoDict:(id)arg1;
+ (id)pathFromShlibInfoDict:(id)arg1;
+ (id)ProjectDirectoryStartUpPath;
+ (id)ProductDirectoryStartUpPath;
+ (id)archivableKeysToBeSkippedByPListArchiver:(id)arg1;
+ (id)archivableRelationships;
+ (id)archivableAttributes;
+ (id)convertArgumentArrayToString:(id)arg1;
+ (id)keyPathsForValuesAffectingDylibVariantSuffix;
+ (id)keyPathsForValuesAffectingHasCustomWorkingDirectory;
+ (id)keyPathsForValuesAffectingLaunchableReferenceAbsolutePath;
+ (id)keyPathsForValuesAffectingLaunchableReferencePath;
@property short dataTipSortType; // @synthesize dataTipSortType=_dataTipSortType;
@property BOOL dataTipCustomDataFormattersEnabled; // @synthesize dataTipCustomDataFormattersEnabled=_dataTipCustomDataFormattersEnabled;
@property BOOL dataTipShowTypeColumn; // @synthesize dataTipShowTypeColumn=_dataTipShowTypeColumn;
@property BOOL showTypeColumn; // @synthesize showTypeColumn=_showTypeColumn;
@property BOOL customDataFormattersEnabled; // @synthesize customDataFormattersEnabled=_customDataFormattersEnabled;
- (id)RADAR_6349422;
- (void)setActiveDevice:(id)arg1;
- (BOOL)isEqualToLastSelectedDevice:(id)arg1;
- (id)activeDevice;
- (BOOL)breakpointsEnabled;
- (void)setBreakpointsEnabled:(BOOL)arg1;
- (void)setVariableFormatDictionary:(id)arg1;
- (id)variableFormatDictionary;
- (void)setDefaultUserSymbolLevel:(NSInteger)arg1;
- (NSInteger)defaultUserSymbolLevel;
- (void)setDefaultSystemSymbolLevel:(NSInteger)arg1;
- (NSInteger)defaultSystemSymbolLevel;
- (id)globalVariable:(id)arg1 inShlib:(id)arg2;
- (void)removeGlobalVariable:(id)arg1 fromShlib:(id)arg2;
- (void)addGlobalVariable:(id)arg1 forShlib:(id)arg2;
- (id)savedGlobalVariables;
- (void)_setLibgmallocEnabled:(BOOL)arg1;
- (BOOL)_libgmallocEnabled;
- (void)_setDisassemblyDisplayState:(NSInteger)arg1;
- (NSInteger)_disassemblyDisplayState;
- (NSInteger)compareName:(id)arg1;
- (NSInteger)activeLaunchConfigIndexForLaunchActionIdentifer:(id)arg1;
- (void)setActiveLaunchConfigIndex:(NSInteger)arg1 forLaunchActionIdentifer:(id)arg2;
- (id)_keyForLaunchActionIdentifierIndex:(id)arg1;
- (id)launchConfigsForLaunchActionIdentifer:(id)arg1;
- (void)setLaunchConfigs:(id)arg1 forLaunchActionIdentifer:(id)arg2;
- (id)_configsDict;
- (id)launchConfigStateForLaunchActionIdentifer:(id)arg1;
- (void)setLaunchConfigState:(id)arg1 forLaunchActionIdentifer:(id)arg2;
- (id)_configStateDict;
- (void)removeShlibInfoAtPath:(id)arg1;
- (void)removeShlibInfoAtIndex:(NSUInteger)arg1;
- (void)setAllShlibInfoToSymbolLevel:(NSInteger)arg1;
- (void)setShlibInfoAtPath:(id)arg1 symbolsLevel:(NSInteger)arg2 symbolsWhenToLoad:(NSInteger)arg3;
- (id)shlibInfoDictForPath:(id)arg1;
- (void)setShlibInfoDict:(id)arg1 symbolsWhenToLoad:(NSInteger)arg2;
- (void)setShlibInfoDict:(id)arg1 symbolsLevel:(NSInteger)arg2;
- (void)_setShlibInfoDictList:(id)arg1;
- (void)_setShlibInfoDictList_v2:(id)arg1;
- (id)shlibInfoDictList_v2;
- (id)_shlibInfoDictList_v2;
- (BOOL)hasGUI;
- (id)displayPath;
- (BOOL)canSetName;
- (void)setName:(id)arg1;
- (id)name;
- (id)activeStartupDirectoryPath;
- (id)activeArgumentString;
- (void)updateActiveEnvironmentToDictionary:(id)arg1;
- (id)primaryRuntimeSystemSpecification;
- (BOOL)isLaunchable;
- (BOOL)_isLaunchableUpToDate;
- (void)invalidateLaunchability;
- (void)_activeBuildConfigurationNameChanged:(id)arg1;
- (void)_activeDeviceChanged:(id)arg1;
- (void)_activeExecutableChanged:(id)arg1;
- (id)cpuTypesOfLaunchable;
- (id)architecturesOfLaunchable;
- (id)fileTypeOfLaunchable;
- (id)absolutePathOfLaunchable;
- (BOOL)hasCustomWorkingDirectory;
- (void)setStartupDirectoryPathType:(int)arg1;
- (int)startupDirectoryPathType;
- (void)setStartupDirectoryPath:(id)arg1;
- (id)startupDirectoryPath;
- (id)rawStartupDirectoryPath;
- (void)setSourceDirectories:(id)arg1;
- (id)sourceDirectories;
- (void)setEnvironmentEntries:(id)arg1;
- (id)environmentEntries;
- (void)setArgumentEntries:(id)arg1;
- (id)argumentEntries;
- (BOOL)autoAttachOnCrash;
- (void)setAutoAttachOnCrash:(BOOL)arg1;
- (BOOL)enableDebugStr;
- (void)setEnableDebugStr:(BOOL)arg1;
- (id)dylibVariantSuffix;
- (void)setDylibVariantSuffix:(id)arg1;
- (void)setDebuggerPlugin:(id)arg1;
- (id)debuggerPlugin;
- (id)launchableReferenceAbsolutePath;
- (id)launchableReferencePath;
- (void)setLaunchableReferencePath:(id)arg1;
- (id)launchableReferenceSourceTree;
- (void)setLaunchableReferenceSourceTree:(id)arg1;
- (id)launchableReference;
- (void)setLaunchableReference:(id)arg1;
- (void)setTarget:(id)arg1;
- (id)target;
- (void)setContainer:(id)arg1;
- (id)container;
- (id)_launchableFileType;
- (void)_setLaunchableFileType:(id)arg1;
- (id)_executableLocation;
- (void)_setExecutableLocation:(id)arg1;
- (id)expandedValueForString:(id)arg1;
- (id)innerDescription;
- (id)gidCommentForArchive;
- (void)_setActiveArgIndices:(id)arg1;
- (id)_activeArgIndices;
- (void)_setEnvironmentEntries:(id)arg1;
- (void)_setArgumentStrings:(id)arg1;
- (id)_argumentStrings;
- (void)awakeFromPListUnarchiver:(id)arg1;
- (id)readFromPListUnarchiver:(id)arg1;
- (void)dealloc;
- (id)init;
- (id)initWithName:(id)arg1;
- (void)_ensureDebuggerPluginIsLoaded;
- (void)moveSourceDirectory:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)removeFromAppleScriptSourceDirectoriesAtIndex:(NSUInteger)arg1;
- (void)replaceInAppleScriptSourceDirectories:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInAppleScriptSourceDirectories:(id)arg1;
- (void)insertInAppleScriptSourceDirectories:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInAppleScriptSourceDirectoriesAtIndex:(NSUInteger)arg1;
- (id)appleScriptSourceDirectories;
- (void)moveEnvironmentVariable:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)removeFromAppleScriptEnvironmentEntriesAtIndex:(NSUInteger)arg1;
- (void)replaceInAppleScriptEnvironmentEntries:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInAppleScriptEnvironmentEntries:(id)arg1;
- (void)insertInAppleScriptEnvironmentEntries:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInAppleScriptEnvironmentEntriesAtIndex:(NSUInteger)arg1;
- (id)appleScriptEnvironmentEntries;
- (void)moveLaunchArgument:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)removeFromAppleScriptArgumentEntriesAtIndex:(NSUInteger)arg1;
- (void)replaceInAppleScriptArgumentEntries:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)insertInAppleScriptArgumentEntries:(id)arg1;
- (void)insertInAppleScriptArgumentEntries:(id)arg1 atIndex:(NSUInteger)arg2;
- (id)valueInAppleScriptArgumentEntriesAtIndex:(NSUInteger)arg1;
- (id)appleScriptArgumentEntries;
- (id)objectSpecifier;

@end

