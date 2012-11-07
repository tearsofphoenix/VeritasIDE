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

@interface OakDocument : NSDocument

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *virtual_path;
@property (nonatomic, retain) NSString *custom_name;
@property (nonatomic, retain) NSString *file_type;
@property (nonatomic, retain) NSString *backup_path;
@property (nonatomic, retain) OakFileEncodingType *fileEncoding;

@property (nonatomic)   BOOL recent_tracking;

@end
