//
//  OakFileReader.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakFileReader.h"
#import "OakDocumentOpenCallback.h"

@implementation OakFileReader

static NSNotificationCenter * s_OakFileReaderNotificationCenter = nil;

static NSNotificationCenter *OakFileReaderCenter(void)
{
    if (!s_OakFileReaderNotificationCenter)
    {
        s_OakFileReaderNotificationCenter = [[NSNotificationCenter alloc] init];
    }

    return s_OakFileReaderNotificationCenter;
}

- (id)initWithPath: (NSString *)path
     authorization: (OakAuthorization *)authorization
           context: (id<OakFileOpenContext>)context
{
    if ((self = [super init]))
    {
        [OakFileReaderCenter() addObserver: self
                                  selector: @selector(handleRequest:)
                                      name: nil
                                    object: nil];
//        _clientKey = read_server().register_client(this);
//        read_server().send_request(_client_key, (request_t){ path, auth });
    }
    
    return self;
}

- (void)dealloc
{
    [OakFileReaderCenter() removeObserver: self];
    
    [super dealloc];
}

- (OakFileReaderResult *)handleRequest: (OakFileReaderRequest *)request
{
    OakFileReaderResult *result = [[OakFileReaderResult alloc] init];
    [result setErrorCode: 0];
    
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [result setAttributes: [fileManager attributesOfItemAtPath: [request path]
                                                         error: &error]];
    if (error)
    {
        NSLog(@"in func: %s error: %@", __func__, error);
    }
    
    return result;
}

- (void)handleReply: (OakFileReaderResult *)result
{
    if(!result.bytes && result.errorCode == ENOENT)
    {
//        _context setCon(NSData *(new io::bytes_t("")), result.attributes);
//        
    }else
    {
//        _context->set_content(result.bytes, result.attributes);
    }
}

@end
