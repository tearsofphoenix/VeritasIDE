//
//  PBXBuildMessage.m
//  DevToolsFoundation
//
//  Created by tearsofphoenix on 12-11-12.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "PBXBuildMessage.h"

static NSArray *s_PBXStringFromType = nil;

@implementation PBXBuildMessage

+ (void)initialize
{
    s_PBXStringFromType = [@[@"Error", @"AnalyzeResult", @"Warning", @"Notice"] retain];
}

+ (id)buildErrorMessageWithFormat: (NSString *)format
{
    
}

+ (id)buildWarningMessageWithFormat: (NSString *)format
{
    
}

+ (id)buildNoticeMessageWithFormat: (NSString *)format
{
    
}

@synthesize buildLogItemIdentifier=_buildLogItemIdentifier;

- (NSString *)description
{
    return [NSString stringWithFormat: @"%@, type: %@ message: %@", [self class], s_PBXStringFromType[_type], _messageString];
}

- (BOOL)isError
{
    return PBXMessageError == _type;
}

- (BOOL)isAnalyzerResult
{
    return PBXMessageAnalyzerResult == _type;
}

- (BOOL)isWarning
{
    return PBXMessageWarning == _type;
}

- (BOOL)isNotice
{
    return PBXMessageNotice == _type;
}

- (NSArray *)submessages
{
    return _submessages;
}

- (void)addSubmessage: (id)submessage
{
    [_submessages addObject: submessage];
}

- (NSUInteger)lineNumber
{
    
}

- (id)filePath
{
    
}

@synthesize fileLocations = _fileLocations;

@synthesize messageString = _messageString;

- (PBXMessageType)type
{
    return _type;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithType: (PBXMessageType)type
     messageString: (NSString *)str
{
    return [self initWithType: type
                messageString: str
                fileLocations: nil];
}

- (id)initWithType: (PBXMessageType)type
     messageString: (NSString *)str
     fileLocations: (NSArray *)fileLocations
{
    if ((self = [super init]))
    {
        _type = type;
        [self setMessageString: str];
        [self setFileLocations: fileLocations];
    }
    
    return self;
}



@end