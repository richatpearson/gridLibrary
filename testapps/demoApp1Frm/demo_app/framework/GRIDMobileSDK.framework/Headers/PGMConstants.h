//
//  PGMConstants.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Authentication
extern NSString *const PGMAuthBase_Staging;
extern NSString *const PGMAuthLoginSuccessUrl_Staging;
extern NSString *const PGMAuthBase_Prod;
extern NSString *const PGMAuthLoginSuccessUrl_Prod;

extern NSString *const PGMAuthLoginLocalPath;
extern NSString *const PGMAuthUseridLocalPath;
extern NSString *const PGMAuthUsernameKey;
extern NSString *const PGMAuthPasswordKey;
extern NSString *const PGMAuthSuccessUrlKey;
extern NSString *const PGMAuthRedirectUrlKey;
extern NSString *const PGMAuthResponseTypeKey;
extern NSString *const PGMAuthResponseType;
extern NSString *const PGMAuthScopeKey;
extern NSString *const PGMAuthScope;
extern NSString *const PGMAuthClientIdKey;

extern NSString *const PGMAuthEscrowBase_Staging;
extern NSString *const PGMAuthEscrowBase_Prod;
extern NSString *const PGMAuthEscrowPoliciesLocalPath;
extern NSString *const PGMAuthConsentPolicyIds;
extern NSString *const PGMAuthConsentSubmitLocalPath;
extern NSString *const PGMAuthConsentSubmitStatus;
extern NSString *const PGMAuthConsentSubmitSuccess;

extern NSString *const PGMAuthMockUsername;
extern NSString *const PGMAuthMockPassword;
extern NSString *const PGMAuthMockAccessToken;
extern NSString *const PGMAuthMockRefreshToken;
extern NSInteger const PGMAuthMockTokenExpiresIn;
extern NSString *const PGMAuthMockPiUserId;

extern NSString *const PGMAuthRefreshTokenBase_Staging;
extern NSString *const PGMAuthRefreshTokenBase_Prod;
extern NSString *const PGMAuthRefreshTokenLocalPath;
extern NSString *const PGMAuthRefreshTokenBodyKey;

// PGMSecureKeychainStorage
extern NSString * const PGMInterAppAccessGroup;
extern NSString * const PGMStorageLabel;
extern NSString * const PGMServiceName;

#pragma mark Classroom

@interface PGMConstants : NSObject

@end
