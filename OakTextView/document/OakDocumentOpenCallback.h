//
//  OakDocumentOpenCallback.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLF                @"\n"
#define kCR                @"\r"
#define kCRLF              @"\r\n"
#define kMIX "•"

#define kFileTypePlainText  @"text.plain"

@class OakDocument;
@class OakBundleCommand;
@class OakAuthorization;

@protocol OakFileOpenContext<NSObject>

@property (nonatomic, retain) OakAuthorization *authorization;

@property (nonatomic, retain) NSString *charsetName;

@property (nonatomic, retain) NSString *lineFeeds;

@property (nonatomic, retain) NSString *fileType;

- (void)filterErrorForCommand: (OakBundleCommand *)command
                           rc: (int)rc
                       output: (NSString *)outPut
                        error: (NSString *)error;
@end

@interface OakFileOpenCallback : NSObject

- (void)obtainForPath: (NSString *) path
        authorization: (OakAuthorization *) auth
              context: (id<OakFileOpenContext>)context;

- (void)selectCharsetForPath: (NSString *)path
                        data: (NSData *)content
                     context: (id<OakFileOpenContext>)context;

- (void)selectLineFeedsFoPath: (NSString *)path
                         data: (NSData *)content
                      context: (id<OakFileOpenContext>)context;

- (void)selectFileTypeForPath: (NSString *)path
                         data: (NSData *)content
                      context: (id<OakFileOpenContext>)context;

- (void)showErrorForPath: (NSString *)path
                 message: (NSString *)message
                  filter: (NSUUID *)filter;

- (void)showContentForPath: (NSString *)path
                      data: (NSData *)content
                attributes: (NSDictionary *)attr
                  fileType: (NSString *)fileType
            pathAttributes: (NSString *)pathAttributes
                  encoding: (NSStringEncoding)encoding
       binaryImportFilters: (NSArray *)filters
         textImportFilters: (NSArray *)textFilters;

@end

@interface OakDocumentOpenCallback : OakFileOpenCallback

- (void)showDocument: (OakDocument *)document
             forPath: (NSString *)path;

- (void)showErrorForPath: (NSString *)path
                document: (OakDocument *)document
                 message: (NSString *)message
                  filter: (NSUUID *)filter;

@end
