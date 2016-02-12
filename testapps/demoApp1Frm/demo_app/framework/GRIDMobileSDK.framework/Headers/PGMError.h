//
//  PGMError.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PGMClientErrorCode)
{
    PGMAuthenticationError                  = 0,
    PGMAuthInvalidCredentialsError          = 1,
    PGMAuthNoConsentError                   = 2,
    PGMAuthRefuseConsentError               = 3,
    PGMCoreNetworkCallError                 = 4,
    PGMAuthUserIdError                      = 5,
    PGMAuthMissingContextError              = 6,
    PGMUnableToStoreContextInKeychainError  = 7,
    PGMAuthConsentFlowError                 = 8,
    PGMAuthMaxRefuseConsentError            = 9,
    PGMAuthUserLoggedOutError               = 10,
    PGMAuthRefreshTokenExpiredError         = 11,
    PGMAuthMissingUserIdError               = 12,
    PGMAuthMissingRefreshTokenError         = 13,
    PGMAuthInvalidClientId                  = 14,
    PGMAuthDeleteUserIdentityIDFromKeychain = 15
};

extern NSString* const PGMErrorDomain;

@interface PGMError : NSObject

/**
 Class method to create an instance of an error.
 
 @param errorCode Error code denoting the problem. See PGMClientErrorCode enumeration for more information.
 @param errorDescription Description for this error.
 
 @return Instance of NSError class.
 */
+ (NSError*) createErrorForErrorCode:(PGMClientErrorCode)errorCode
                          andDescription:(NSString*)errorDescription;

@end
