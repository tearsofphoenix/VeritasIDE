//
//  OakAuthorizationHelper.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakAuthorizationHelper.h"

@interface OakAuthorizationHelper ()
{
    AuthorizationRef _authorization;
    BOOL _valid;
}
@end

@implementation OakAuthorizationHelper

- (id)initWithHexString: (NSString *)hexString;
{
    if ((self = [super init]))
    {
        _valid = NO;
        
        NSUInteger hexLength = [hexString length];
        if(hexLength / 2 == sizeof(AuthorizationExternalForm))
        {
            char v[hexLength / 2];
            for(NSUInteger i = 0; i + 1 < hexLength; i += 2)
            {
                v[i / 2] = (strtol([[hexString substringWithRange: NSMakeRange(i, 2)] UTF8String], NULL, 16));
            }
            
            AuthorizationExternalForm const* extAuth = (AuthorizationExternalForm const*)&v[0];
            if(errAuthorizationSuccess == AuthorizationCreateFromExternalForm(extAuth, &_authorization))
            {
                _valid = YES;
            }
        }
    }
    
    return self;
}

- (id)init
{
    return [self initWithHexString: nil];
}

- (void)dealloc
{
    if(_valid)
    {
        AuthorizationFree(_authorization, kAuthorizationFlagDestroyRights);
    }
    
    [super dealloc];
}

- (BOOL)copyright: (NSString *)right
             flag:  (AuthorizationFlags) flags
{
    [self setup];
    
    if(!_valid)
    {
        return false;
    }
    
    AuthorizationItem rightsItems[]     = { { [right UTF8String], 0, NULL, 0 }, };
    AuthorizationRights const allRights = { sizeof(rightsItems), rightsItems };
    
    BOOL res = false;
    AuthorizationRights* myAuthorizedRights = NULL;
    int myStatus = AuthorizationCopyRights(_authorization, &allRights, kAuthorizationEmptyEnvironment, flags, &myAuthorizedRights);
    if(myStatus == errAuthorizationSuccess)
    {
        res = true;
        AuthorizationFreeItemSet(myAuthorizedRights);
    }
    else if(myStatus == errAuthorizationCanceled)
    {
        fprintf(stderr, "authorization (pid %d): user canceled\n", getpid());
    }
    else if(myStatus == errAuthorizationDenied)
    {
        fprintf(stderr, "authorization (pid %d): rights denied\n", getpid());
    }
    else if(myStatus == errAuthorizationInteractionNotAllowed)
    {
        fprintf(stderr, "authorization (pid %d): interaction not allowed\n", getpid());
    }
    else
    {
        fprintf(stderr, "authorization (pid %d): error %d\n", getpid(), myStatus);
    }
    return res;
}

- (AuthorizationRef)reference
{
    return _authorization;
}

- (NSString *)description
{
    NSMutableString *res = [NSMutableString string];
    AuthorizationExternalForm extAuth;
    if(AuthorizationMakeExternalForm(_authorization, &extAuth) == errAuthorizationSuccess)
    {
        [res appendFormat: @"%s", extAuth.bytes];
    }
    
    return res;
}

- (void)setup
{
    _valid = _valid
    || AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &_authorization) == errAuthorizationSuccess;
}


@end
