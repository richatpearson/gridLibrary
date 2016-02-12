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

@interface PGMAuthenticator : NSObject

@property (nonatomic, strong) PGMAuthOptions *options;
@property (nonatomic, strong) PGMEnvironment *environment;
@property (nonatomic, strong) PGMAuthConnector *authConnector;
@property (nonatomic, strong) PGMAuthKeychainStorageManager *authKeychainStorageManager;
@property (nonatomic, strong) PGMConsentConnector *consentConnector;

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


@end
