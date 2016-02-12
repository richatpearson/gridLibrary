//
//  PGMConstants.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMConstants.h"

#pragma mark Authentication
NSString *const PGMAuthBase_Staging            = @"https://int-piapi.stg-openclass.com/v1/piapi-int/";
NSString *const PGMAuthLoginSuccessUrl_Staging = @"http://int-piapi.stg-openclass.com/pioauth-int/authCode";

NSString *const PGMAuthBase_Prod               = @"https://piapi.openclass.com/v1/piapi/";
NSString *const PGMAuthLoginSuccessUrl_Prod    = @"http://piapi.openclass.com/pioauth/authCode";

NSString *const PGMAuthLoginLocalPath        = @"login/credentials";
NSString *const PGMAuthUseridLocalPath       = @"credentials/?username=";
NSString *const PGMAuthUsernameKey           = @"username";
NSString *const PGMAuthPasswordKey           = @"password";
NSString *const PGMAuthSuccessUrlKey         = @"login_success_url";
NSString *const PGMAuthRedirectUrlKey        = @"redirect_url";
NSString *const PGMAuthResponseTypeKey       = @"response_type";
NSString *const PGMAuthResponseType          = @"code";
NSString *const PGMAuthScopeKey              = @"scope";
NSString *const PGMAuthScope                 = @"s2";

NSString *const PGMAuthClientIdKey                  = @"client_id";
NSString *const PGMAuthForgotUsername               = @"login/forgotusername";
NSString *const PGMAuthForgotPassword               = @"login/forgotpassword";
NSString *const PGMAuthForgotUsernameEmailNotFound  = @"piui.noSuchEmailAddress";
NSString *const PGMAuthForgotPasswordNoSuchUsername = @"piui.noSuchUsername";
NSString *const PGMAuthForgotPasswordTooManyTickets = @"piui.tooManytickets";

NSString *const PGMAuthEscrowBase_Staging         = @"https://escrow.stg-openclass.com/";
NSString *const PGMAuthEscrowBase_Prod            = @"https://escrow.prd-prsn.com/";
NSString *const PGMAuthEscrowPoliciesLocalPath    = @"escrow/";
NSString *const PGMAuthConsentPolicyIds           = @"policyIds";
NSString *const PGMAuthConsentSubmitLocalPath     = @"login/redeemEscrow/";
NSString *const PGMAuthConsentSubmitStatus        = @"status";
NSString *const PGMAuthConsentSubmitSuccess       = @"success";

NSString *const PGMAuthMockUsername               = @"user";
NSString *const PGMAuthMockPassword               = @"password";
NSString *const PGMAuthMockAccessToken            = @"mockToken4EdDfuqIiZA1Uer3RsJ";
NSString *const PGMAuthMockRefreshToken           = @"mockRefreshTokenf4PGJGKHLa70wpzT";
NSInteger const PGMAuthMockTokenExpiresIn         = 2000;
NSString *const PGMAuthMockPiUserId               = @"ffffffffmockUserIdb06dc3155ccc55";

NSString *const PGMAuthRefreshTokenBase_Staging   = @"https://int-piapi.stg-openclass.com/pioauth-int/";
NSString *const PGMAuthRefreshTokenBase_Prod      = @"https://piapi.openclass.com/pioauth/";
NSString *const PGMAuthRefreshTokenLocalPath      = @"refresh";
NSString *const PGMAuthRefreshTokenBodyKey        = @"grant_type=refresh_token&refresh_token";

// PGMSecureKeychainStorage
NSString * const PGMInterAppAccessGroup     = @"Grid_Mobile_Platform_Inter_App_Access_Group_1";
NSString * const PGMStorageLabel            = @"Grid_Mobile_Platform_Label";
NSString * const PGMServiceName             = @"Grid_Mobile_Platform_Authentication_Service";



#pragma mark Classroom

@implementation PGMConstants

@end
