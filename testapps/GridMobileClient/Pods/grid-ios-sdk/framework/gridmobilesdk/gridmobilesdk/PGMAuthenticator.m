//
//  PGMAuthenticator.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthenticator.h"
#import "PGMAuthFactory.h"
#import "PGMConsentPolicy.h"

@interface PGMAuthenticator()

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) PGMAuthResponse *authResponse;
@property (nonatomic, strong) AuthenticationRequestComplete clientOnComplete;

@end

@implementation PGMAuthenticator

-(instancetype) initWithEnvironment:(PGMEnvironment*)environment
                         andOptions:(PGMAuthOptions*)options {
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    if (environment) {
        self.environment = environment;
    }
    
    if (options) {
        self.options = options;
    }
    
    [self setConnector:[PGMAuthFactory createAuthConnectorWithEnvironment:environment andClientOptions:options]];
    [self setKeychainStorageManager:[PGMAuthFactory createAuthKeychainStorageManager]];
    self.consentConnector = [PGMAuthFactory createConsentConnectorWithEnvironment:environment];
    //[self setConsentConnector:[PGMAuthFactory createConsentConnectorWithEnvironment:environment]];
    
    return self;
}

-(void) setConnector:(PGMAuthConnector*)connector {
    self.authConnector = connector;
}

-(void) setKeychainStorageManager:(PGMAuthKeychainStorageManager*)keychainStorageManager {
    self.authKeychainStorageManager = keychainStorageManager;
}

/*-(void) setConsentConnector:(PGMConsentConnector *)consentConnector {
    self.consentConnector = consentConnector;
}*/

- (PGMAuthContextValidator*) authContextValidator
{
    if (!_authContextValidator)
    {
        _authContextValidator = [[PGMAuthContextValidator alloc] init];
    }
    return _authContextValidator;
}

-(void) authenticateWithUserName:(NSString*)username
                     andPassword:(NSString*)password
                      onComplete:(AuthenticationRequestComplete)completionHandler {
    self.authResponse = [PGMAuthResponse new];
    self.clientOnComplete = completionHandler;
    
    if(![self validateCredentialsWithUsername:username andPassword:password]) {
        self.authResponse.error = self.error;
        completionHandler(self.authResponse);
        return;
    }
    
    AuthConnectorRequestComplete connectorCompletionHandler = ^(PGMAuthResponse *response) {
        if (response.error) {
            NSLog(@"Authenticator - in onComplete for login - error: %@", response.error.description);
            if (response.error.code == 2) { //PGMAuthNoConsentError
                [self obtainConsentPoliciesForEscrowTicket:response.escrowTicket];
            } else {
                self.clientOnComplete(response);
            }
        }
        else {
            NSLog(@"Authenticator - in onComplete for login - will call user Id request");
            if ([self hasAccessTokenForResponse:response]) {
                [self obtainUserIdWithResponse:response];
            }
        }
    };
    
    [self.authConnector runAuthenticationRequestWithUsername:username
                                                    password:password
                                                 andResponse:self.authResponse
                                                  onComplete:connectorCompletionHandler];
}

-(BOOL) hasAccessTokenForResponse:(PGMAuthResponse*)response {
    if (response.authContext && response.authContext.accessToken && ![response.authContext.accessToken isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

-(void) obtainUserIdWithResponse:(PGMAuthResponse*)response {
    AuthConnectorRequestComplete connectorCompletionHandler = ^(PGMAuthResponse *response) {
        if (!response.error) {
            NSError *keychainError = nil;

            if (![self storeAuthContext:response.authContext error:&keychainError] && keychainError) {
                response.error = keychainError;
            }
            
        }
        
        NSLog(@"Authenticator - in onComplete for user id - returning client's onComplete");
        self.clientOnComplete(response);
    };
    
    [self.authConnector runUserIdRequestWithResponse:response onComplete:connectorCompletionHandler];
}

- (BOOL) validateCredentialsWithUsername:(NSString*)username
                             andPassword:(NSString*)password
{
    if ((!username) || [username isEqualToString:@""])
    {
        self.error = [[NSError alloc] init];
        NSString *errorDesc = @"Missing username.";
        
        self.error = [PGMError createErrorForErrorCode:PGMAuthenticationError
                                        andDescription:errorDesc];
        return NO;
    }
    
    if ((!password) || [password isEqualToString:@""])
    {
        self.error = [[NSError alloc] init];
        NSString *errorDesc = @"Missing password.";
        
        self.error = [PGMError createErrorForErrorCode:PGMAuthenticationError
                                        andDescription:errorDesc];
        return NO;
    }
    
    return YES;
}

-(BOOL) storeAuthContext:(PGMAuthenticatedContext*)context
                   error:(NSError**)error {
    
    
    BOOL storeResult = [self.authKeychainStorageManager storeKeychainAuthenticatedContext:context error:*&error];
    if (!*error && !storeResult) {
        *error = [PGMError createErrorForErrorCode:PGMUnableToStoreContextInKeychainError
                                    andDescription:@"Unable to store context in keychain."];
    }
    
    return storeResult;
}

-(void) obtainConsentPoliciesForEscrowTicket:(NSString*)escrowTicket {
    
    [self.consentConnector runPoliciesRequestWithEscrowTicket:escrowTicket
                                                  forResponse:self.authResponse
                                                   OnComplete:self.clientOnComplete];
}

-(void) submitUserConsentPolicies:(NSArray*)policies
                     withUsername:(NSString*)username
                         password:(NSString*)password
                     escrowTicket:(NSString*)escrowTicket
                       onComplete:(AuthenticationRequestComplete)onComplete {
    NSLog(@"Submitting user's consent policies...");
    self.clientOnComplete = onComplete;
    PGMAuthResponse *response = [[PGMAuthResponse alloc] init];
    
    NSError *error = nil;
    if ([self validateUserConsentForPolicies:policies escrowTicket:escrowTicket error:&error]) {
        
        AuthenticationRequestComplete postConsentCompletionHandler = ^(PGMAuthResponse *response) {
            if (response.error) {
                self.clientOnComplete(response);
            } else {
                NSLog(@"Authenticator - in postConsentCompletionHandler - success posting consents. Will attempt to login.");
                [self authenticateWithUserName:username
                                   andPassword:password
                                    onComplete:self.clientOnComplete];
            }
        };
        
        [self.consentConnector runConsentSubmissionForPolicyIds:policies
                                                   escrowTicket:escrowTicket
                                                       response:response
                                                     onComplete:postConsentCompletionHandler];
    }else { //did not consent to all policies
        NSLog(@"Failed post consent args validation");
        response.error = error;
        response.consentPolicies = [self resetConsentPolicies:policies];
        response.escrowTicket = escrowTicket;
        self.clientOnComplete(response);
    }
}

-(BOOL) validateUserConsentForPolicies:(NSArray*)policies
                          escrowTicket:(NSString*)escrowTicket
                                 error:(NSError**)error {
    if (!escrowTicket || [escrowTicket isEqualToString:@""]) {
        if ( error != nil ) {
            *error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription: @"No escrow ticket included in request"];
        }
        return NO;
    }
    
    if (!policies || policies.count < 1) {
        if ( error != nil ) {
            *error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription: @"No policy Ids included in request"];
        }
        return NO;
    }
    
    for (PGMConsentPolicy *policy in policies) {
        if (!policy.isConsented) {
            if ( error != nil ) {
                *error = [PGMError createErrorForErrorCode:PGMAuthRefuseConsentError andDescription: @"User refused consent"];
            }
            return NO;
        }
    }
    
    return YES;
}

-(NSArray*) resetConsentPolicies:(NSArray*)consentPolicies {
    for (PGMConsentPolicy *policy in consentPolicies) {
        if (!policy.isConsented) {
            policy.isReviewed = NO;
        }
    }
    return consentPolicies;
}

-(PGMAuthResponse *)logoutUserWithAuthenticatedContext:(PGMAuthenticatedContext *)context {
    PGMAuthResponse *logoutPGMAuthResponse = [PGMAuthResponse new];
    NSError  *logoutError;
    NSString *errorDescription;
    if ( [self isValidContext:context] == TRUE ) {
        // We received a valid userIdentityId
        BOOL successfullyDeletedUserFromKeychain = [self.authKeychainStorageManager deleteAuthContextForIdentifier:context.userIdentityId];
        if ( successfullyDeletedUserFromKeychain == FALSE ) {
            errorDescription = [NSString stringWithFormat:@"%@%@%@", @"PGMAuthenticator had a problem deleting the user from the Keychain:  ", context.userIdentityId, @"."];
            logoutError = [PGMError createErrorForErrorCode:PGMAuthDeleteUserIdentityIDFromKeychain andDescription:errorDescription];
            logoutPGMAuthResponse.error = logoutError;
        } else {
            NSLog(@"PGMAuthenticator logout - successfully deleted user from the Keychain:  %@.", context.userIdentityId);
            self.authResponse = nil;
        }
    } else {
        errorDescription = [NSString stringWithFormat:@"%@", @"PGMAuthenticator will not attempt to delete an invalid context.userIdentityId from the Keychain because the context.userIdentityId is either nil, or an empty string."];
        logoutError = [PGMError createErrorForErrorCode:PGMAuthMissingUserIdError andDescription:errorDescription];
        logoutPGMAuthResponse.error = logoutError;
    }
    return logoutPGMAuthResponse;
}

-(BOOL)isValidContext:(PGMAuthenticatedContext *)context {
    BOOL    hasValidContext = FALSE;
    if ( context == nil  || context.userIdentityId == nil || [context.userIdentityId isEqualToString:@""] ) {
        hasValidContext = FALSE;
    } else {
        hasValidContext = TRUE;
    }
    return  hasValidContext;
}

#pragma mark forgot username/password
-(void) forgotUsernameForEmail:(NSString *)email
                    onComplete:(AuthenticationRequestComplete)onComplete {
    
    PGMAuthResponse *response = [PGMAuthResponse new];
    
    if ([self isEmailValid:email]) {
        NSLog(@"Valid email format - will call connector");
        [self.authConnector runForgotUsernameForEmail:email
                                         withResponse:response
                                           onComplete:onComplete];
    }
    else {
        NSLog(@"Invalid email - error");
        response.error = [PGMError createErrorForErrorCode:PGMAuthInvalidEmailError andDescription:@"Invalid email"];
        onComplete(response);
    }
}

-(BOOL) isEmailValid:(NSString*)email {
    return (email && ![email isEqualToString:@""] && [self isCorrectFormatEmail:email]);
}

-(BOOL) isCorrectFormatEmail:(NSString *)checkEmail
{
    NSString *emailRegex = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"; //lax validation
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
}

- (void) forgotPasswordForUsername:(NSString*)username
                        onComplete:(AuthenticationRequestComplete)onComplete {
    PGMAuthResponse *response = [PGMAuthResponse new];
    
    if ([self isUsernameMissing:username]) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthMissingUsernameError
                                            andDescription:@"Username is required for 'forgot password' request"];
        onComplete(response);
    }
    else {
        [self.authConnector runForgotPasswordForUsername:username
                                            withResponse:response
                                              onComplete:onComplete];
    }
}

-(BOOL) isUsernameMissing:(NSString*)username {
    return (!username || [username isEqualToString:@""]);
}

- (void) obtainCurrentTokenForAuthContext:(PGMAuthenticatedContext*)authContext
                               onComplete:(AuthenticationRequestComplete)onComplete {

    [self.authContextValidator provideCurrentTokenForAuthContext:authContext
                                                     environment:self.environment
                                                         options:self.options
                                                      onComplete:onComplete];
}

- (void) obtainCurrentTokenForExpiredAuthContext:(PGMAuthenticatedContext*)authContext
                                      onComplete:(AuthenticationRequestComplete)onComplete {
    
    [self.authContextValidator provideCurrentTokenForExpiredAuthContext:authContext
                                                            environment:self.environment
                                                                options:self.options
                                                             onComplete:onComplete];
}

@end











