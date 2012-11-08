//
//  OakDocument.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakDocument;
@class OakFileEncodingType;
@class OakDocumentMark;

enum
{
    OakDocumentEventDidSave,
    
    OakDocumentEventdid_change_open_status,
    OakDocumentEventdid_change_modified_status,
    OakDocumentEventdid_change_on_disk_status,
    OakDocumentEventdid_change_path,
    OakDocumentEventdid_change_file_type,
    OakDocumentEventdid_change_indent_settings,
    // did_change_display_name,
    OakDocumentEventdid_change_marks,
    // did_change_symbols,
};

typedef NSInteger OakDocumentEventType;

typedef void(^ OakDocumentCallback)(OakDocument *doc, OakDocumentEventType event);

@interface OakDocument : NSObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *virtualPath;
@property (nonatomic, retain) NSString *customName;
@property (nonatomic, retain) NSString *fileType;
@property (nonatomic, retain) NSString *backupPath;
@property (nonatomic, retain) OakFileEncodingType *fileEncoding;

@property (nonatomic)   BOOL recent_tracking;


- (id<OakDocumentReader>)createReader;

// ======================================================
// = Performing replacements (from outside a text view) =
// ======================================================

- (void)replaceContentWith: (NSDictionary *)replacements;

- (void)addMark: (OakDocumentMark *)mark
        atRange: (OakTextRange *)range;

- (void)removeAllMarksWithTypeToClear: (NSString *)typeToClear;

- (NSDictionary *)allMarks;

- (NSString *)marksAsString;

- (NSDictionary *)symbols;

- (void)addCallback: (OakDocumentCallback)callback;

- (void)removeCallback: (OakDocumentCallback)callback;

- (void)checkModified: (ssize_t) diskRev
             received: (ssize_t)rev;

- (void)broadcastEvent: (OakDocumentEventType)event
               cascade: (BOOL)cascade;

// ===================
// = For OakTextView =
// ===================

- (void)postLoadForPath: (NSString *)path
                content: (NSData *) content
             attributes: (NSDictionary *)attributes
               fileType: (NSString *)fileType
         pathAttributes: (NSString *) pathAttributes
               encoding: (OakFileEncodingType * )encoding;

- (void)postSaveToPath: (NSString *) path
               content: (NSData *)content
        pathAttributes: (NSString *) pathAttributes
              encoding: (OakFileEncodingType *) encoding
                succes: (BOOL) succes;


- (BOOL)tryOpenWithCallback: (OakDocumentCallback)callback;

- (void)open;

- (void)close;

- (void)show;

- (void)hide;

- (NSDate *)lru;

- (void)trySaveWithCallback: (OakDocumentCallback)callback;

- (BOOL)save;

- (BOOL)backup;

- (NSString *)buffer;

- (NSUndoManager *)undoManager;

// =============
// = Accessors =
// =============

- (NSUUID *)identifier;

- (NSInteger)revision;

- (void)setRevision: (NSInteger)rev;

- (BOOL)isOpen;

- (NSString *)fileType;

- (NSDictionary *)settings;

- (NSDictionary *)variablesWith: (NSDictionary *)map
             isSourceFileSystem: (BOOL)sourceFileSystem;

- (BOOL)isModified;

-(BOOL)isOnDisk;

- (void)setDiskRevision: (NSInteger)rev;

- (NSString *)selection;

- (NSString *)folded;

- (NSString *)visibleRect;

- (void)setSelection: (NSString *)sel;

- (void)setFolded: (NSString *)folded;

- (void)setVisibleRect: (NSString *)rect;

- (void)setAuthorization: (OakAuthorization *)auth;

- (scope_t)scope;

- (void)_setupBuffer;

- (void)grammarDidChange;

- (void)setContent: (NSData *)bytes;

- (NSString *)content;

- (void)setModified: (BOOL)flag;

// ==============
// = Properties =
// ==============

+ (OakDocument *)documentWithPath: (NSString *)path;

+ (OakDocument *)documentFromContent: (NSString *)content
                            fileType: (NSString *)fileType;

+ (OakDocument *)documentWithUUID: (NSUUID *)uuid
                    searchBackups: (BOOL)flag;

- (NSUInteger)untitledCount;

- (void)watchCallbackWithFlag: (int) flags
                         path: (NSString *)newPath
                        async: (BOOL)async;

@end
