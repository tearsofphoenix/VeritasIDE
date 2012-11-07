//
//  OakFileReader.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OakAuthorization;
@protocol OakFileOpenContext;

@interface OakFileReaderRequest : NSObject

@property (nonatomic, retain) NSString *path;

@property (nonatomic, retain) OakAuthorization *authorization;

@end

@interface OakFileReaderResult : NSObject

@property (nonatomic, retain) NSData *bytes;

@property (nonatomic, retain) NSDictionary *attributes;

@property (nonatomic) NSInteger errorCode;

@end

@interface OakFileReader : NSObject
{
    NSUInteger _clientKey;
    id<OakFileOpenContext> _context;
}

- (id)initWithPath: (NSString *)path
     authorization: (OakAuthorization *)authorization
           context: (id<OakFileOpenContext>)context;


- (void)handleReply: (OakFileReaderResult *)result;
    
@end

extern OakFileReaderResult OakFileReaderHandleRequest(OakFileReaderRequest *request);
