#include "merge.h"

#import <OakFoundation/OakFoundation.h>

static NSString * save (NSString * buf)
{
	NSString * dst = [NSTemporaryDirectory() stringByAppendingString: @"textmate_merge.XXXXXX"];
    
    NSError *error = nil;
    
    [buf writeToFile: dst
          atomically: YES
            encoding: NSUTF8StringEncoding
               error: &error];
    
    return dst;
}

void merge (NSString * oldContent,
            NSString * myContent,
            NSString * yourContent,
            bool* conflict)
{
	NSString * oldFile  = save(oldContent);
	NSString * myFile   = save(myContent);
	NSString * yourFile = save(yourContent);
    
	assert(oldFile  && myFile && yourFile );
    
    dispatch_async(dispatch_get_current_queue(),
                   (^
                    {
                        NSString *commandString = [NSString stringWithFormat: @"-Em -L 'Local Changes' -L 'Old File' -L 'External Changes' '%@' '%@' '%@'",
                                                   myFile, oldFile, yourFile];
                        
                        [NSTask launchedTaskWithLaunchPath: @"#!/bin/sh\n/usr/bin/diff3"
                                                 arguments: @[ commandString ]];
                        
                        unlink([oldFile UTF8String]);
                        unlink([myFile UTF8String]);
                        unlink([yourFile UTF8String]);
                        
                    }));
    
}
