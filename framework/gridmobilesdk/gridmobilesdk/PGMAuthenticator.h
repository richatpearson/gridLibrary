//
//  PGMAuthenticator.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthOptions.h"
#import "PGMAuthResponse.h"
#import "PGMEnvironment.h"
#import "PGMAuthConnector.h"
#import "PGMAuthKeychainStorageManager.h"
#import "PGMConsentConnector.h"
#import "PGMAuthContextValidator.h"


@interface PGMAuthenticator : NSObject

@property (nonatomic, strong) PGMAuthOptions *options;
@property (nonatomic, strong) PGMEnvironment *environment;
@property (nonatomic, strong) PGMAuthConnector *authConnector;
@property (nonatomic, strong) PGMAuthKeychainStorageManager *authKeychainStorageManager;
@property (nonatomic, strong) PGMConsentConnector *consentConnector;
@property (nonatomic, strong) PGMAuthContextValidator *authContextValidator; 


-(instancetype) initWithEnvironment:(PGMEnvironment*)environment
                         andOptions:(PGMAuthOptions*)options;

-(void) setConnector:(PGMAuthConnector*)connector;
-(void) setKeychainStorageManager:(PGMAuthKeychainStorageManager*)keychainStorageManager;
-(void) setConsentConnector:(PGMConsentConnector *)consentConnector;

-(void) authenticateWithUserName:(NSString*)username
                     andPassword:(NSString*)password
                      onComplete:(AuthenticationRequestComplete)completionHandler;

-(void) submitUserConsentPolicies:(NSArray*)policies
                     withUsername:(NSString*)username
                         password:(NSString*)password
                     escrowTicket:(NSString*)escrowTicket
                       onComplete:(AuthenticationRequestComplete)onComplete;

-(PGMAuthResponse *)logoutUserWithAuthenticatedContext:(PGMAuthenticatedContext *)context;

/*!
 Submits email address to retrieve forgotten username and then calls client's onComplete block.
 
 @param email      Email address submitted by user
 @param onComplete AuthenticationRequestComplete block called when submission is complete - the framework
        will provide PGMAuthResponse (the authentication response object) as the input parameter
 */
-(void) forgotUsernameForEmail:(NSString *)email
                               onComplete:(AuthenticationRequestComplete)onComplete;

/*!
 Submits a username to the Forgot Password service
 
 @param username   Username as entered by user
 @param onComplete AuthenticationRequestComplete block to be called when request is complete - the framework
    will provide PGMAuthResponse (the authentication response object) as the input parameter
 */
- (void) forgotPasswordForUsername:(NSString*)username
                                  onComplete:(AuthenticationRequestComplete)onComplete;

/*!
 Obtains a valid token for user's request
 
 @param authContext authenticated context for user obtained during sign in process
 @param onComplete AuthenticationRequestComplete block to be called when request is complete - the framework
    will provide PGMAuthResponse (the authentication response object) as the input parameter
 */
- (void) obtainCurrentTokenForAuthContext:(PGMAuthenticatedContext*)authContext
                               onComplete:(AuthenticationRequestComplete)onComplete;

/*!
 Obtains a valid token for user's request in case the previous request resulted in
    "keymanagement.service.access_token_expired" error from Pi
 
 @param authContext authenticated context for user obtained during sign in process
 @param onComplete AuthenticationRequestComplete block to be called when request is complete - the framework
 will provide PGMAuthResponse (the authentication response object) as the input parameter
 */
- (void) obtainCurrentTokenForExpiredAuthContext:(PGMAuthenticatedContext*)authContext
                                      onComplete:(AuthenticationRequestComplete)onComplete;

@end







