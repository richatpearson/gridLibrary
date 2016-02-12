//
//  PGMAuthTokenValidator.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/29/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthContextValidator.h"
#import "PGMAuthFactory.h"
#import "PGMEnvironment.h"

@interface PGMAuthContextValidator()

//@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) PGMAuthResponse *response;
@property (nonatomic, strong) PGMEnvironment *environment;
@property (nonatomic, strong) PGMAuthOptions *userOptions;
@property (nonatomic, strong) AuthenticationRequestComplete clientCompletionHanlder;
//@property (nonatomic, strong) NSString *userIdentifier;

@end

@implementation PGMAuthContextValidator

- (instancetype) init {
    self = [super init];
    if (self)
    {
        NSLog(@"Initializing samaphore and queue...");
        semaphore = dispatch_semaphore_create(0);
        serialQueue = dispatch_queue_create("com.rich.threadTestingSync", NULL);
    }
    return self;
}

- (PGMAuthKeychainStorageManager*)keychainStorageManager {
    if (!_keychainStorageManager) {
        _keychainStorageManager = [PGMAuthFactory createAuthKeychainStorageManager];
    }
    return _keychainStorageManager;
}

- (PGMAuthConnector*)authConnector {
    if (!_authConnector) {
        _authConnector = [PGMAuthFactory createAuthConnectorWithEnvironment:self.environment
                                                           andClientOptions:self.userOptions];
    }
    return _authConnector;
}

#pragma mark Network call needs a current auth context scenario:

- (void) provideCurrentTokenForAuthContext:(PGMAuthenticatedContext*)authContext
                              environment:(PGMEnvironment*)environment
                                  options:(PGMAuthOptions*)userOptions
                               onComplete:(AuthenticationRequestComplete)completionHandler {
    
    PGMAuthResponse *responseToClient = [PGMAuthResponse new];
    self.environment = environment;
    self.userOptions = userOptions;
    
    NSError *argError = nil;
    if ([self isAuthContextForUserEmpty:authContext error:&argError]) {
        responseToClient.error = argError;
        completionHandler(responseToClient);
        return;
    }
    
    //self.userIdentifier = userId;
    NSLog(@"About to add this task to a serial queue...");
    dispatch_async(serialQueue, ^{ //non-blocking to the calling thread
        NSLog(@"Request in serial queue - thread id is: %@", [NSThread currentThread]);
        self.response = responseToClient;
        [self obtainAuthContextForUser:authContext.userIdentityId onComplete:completionHandler];
    });
}

- (BOOL) isAuthContextForUserEmpty:(PGMAuthenticatedContext*)authContext
                            error:(NSError**)error {
    if (!authContext) {
        if ( error != nil ) {
            *error = [PGMError createErrorForErrorCode:PGMAuthMissingContextError
                                        andDescription:@"Authenticated context for user must be provided"];
        }
        return true;
    }
    
    if (!authContext.userIdentityId || [authContext.userIdentityId isEqualToString:@""]) {
        if ( error != nil ) {
            *error = [PGMError createErrorForErrorCode:PGMAuthMissingUserIdError
                                        andDescription:@"User id must be provided as part of authenticated context"];
        }
        return true;
    }
    return false;
}

- (BOOL) isAuthContextWithTokenEmpty:(PGMAuthenticatedContext*)authContext
                               error:(NSError**)error {
    
    BOOL missingUserId = [self isAuthContextForUserEmpty:authContext error:&*error];
    
    if (missingUserId) {
        return true;
    }
    
    if (!authContext.accessToken || [authContext.accessToken isEqualToString:@""]) {
        if ( error != nil ) {
            *error = [PGMError createErrorForErrorCode:PGMAuthMissingAccessTokenInContextError
                                        andDescription:@"Access token must be provided as part of authenticated context"];
        }
        return true;
    }
    return false;
}

- (void) obtainAuthContextForUser:(NSString*)userId
                      onComplete:(AuthenticationRequestComplete)completionHandler {
    
    NSError *error = nil;
    PGMAuthenticatedContext *authContext = [self obtainContextFromStorageForUser:userId error:&error];
    if (error) {
        self.response.error = error;
        completionHandler(self.response);
    }
    else {
        if (authContext.isTokenCurrent) {
            self.response.authContext = authContext;
            completionHandler(self.response);
        }
        else { //token expired - need to refresh
            NSLog(@"Expired context...");
            self.clientCompletionHanlder = completionHandler;
            [self requestRefreshTokenForAuthContext:authContext];
        }
    }
}

- (PGMAuthenticatedContext*) obtainContextFromStorageForUser:(NSString*)userId
                                                      error:(NSError**)error {
    
    PGMAuthenticatedContext *authContext = [self.keychainStorageManager retrieveAuthContextForIdentifier:userId];
    
    if (!authContext) { //user must have previously logged out
        if (error != nil) {
            *error = [PGMError createErrorForErrorCode:PGMAuthUserLoggedOutError
                                    andDescription:@"No auth context in keychain - user must log in again."];
        }
    }
    return authContext;
}

- (void) requestRefreshTokenForAuthContext:(PGMAuthenticatedContext*)authContext {
    
    AuthenticationRequestComplete connectorCompletionHandler = ^(PGMAuthResponse *response) {
        if (!response.error) {
            if (response.authContext) {
                response.authContext.userIdentityId = authContext.userIdentityId;
                response.authContext.username = authContext.username;
            }
            
            NSError *keychainError = nil;
            if (![self.keychainStorageManager storeKeychainAuthenticatedContext:response.authContext error:&keychainError]) {
                response.error = [PGMError createErrorForErrorCode:PGMUnableToStoreContextInKeychainError
                                                    andDescription:@"Unable to store context in keychain."];
            }
        } else {
            [self deleteAuthContextForExpiredRefreshTokenErrorCode:response.error.code
                                                        identifier:authContext.userIdentityId];
                                                        //identifier:self.userIdentifier];
        }
        
        NSLog(@"AuthContextValidator - in onComplete for refresh token - returning client's onComplete");
        self.clientCompletionHanlder(response);
        
        dispatch_semaphore_signal(semaphore);
    };
    
    [self.authConnector runRefreshTokenWithResponse:self.response
                                        authContext:authContext
                                         onComplete:connectorCompletionHandler];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //The task has not completed yet so we are waiting until the task is done and only then the next task will go in serial our queue
    NSLog(@"Opening semaphore after completion handler ran... - thread id is: %@", [NSThread currentThread]);
}

- (void) deleteAuthContextForExpiredRefreshTokenErrorCode:(NSInteger)errorCode
                                                 identifier:(NSString*)identifier {
    if (errorCode == PGMAuthRefreshTokenExpiredError) {
        NSLog(@"Deleting auth context for id %@ due to expired refresh token", identifier);
        [self.keychainStorageManager deleteAuthContextForIdentifier:identifier];
    }
}

#pragma mark Network call reported expired access token scenario:

- (void) provideCurrentTokenForExpiredAuthContext:(PGMAuthenticatedContext*)authContext
                                     environment:(PGMEnvironment*)environment
                                         options:(PGMAuthOptions*)userOptions
                                      onComplete:(AuthenticationRequestComplete)completionHandler {
    
    self.environment = environment;
    self.userOptions = userOptions;
    
    PGMAuthResponse *responseToClient = [PGMAuthResponse new];
    
     NSError *argError = nil;
     if ([self isAuthContextWithTokenEmpty:authContext error:&argError]) {
         responseToClient.error = argError;
         completionHandler(responseToClient);
         return;
     }
    
    NSLog(@"About to add this task to a serial queue...");
    dispatch_async(serialQueue, ^{ //non-blocking to the calling thread
        NSLog(@"Request in serial queue - thread id is: %@", [NSThread currentThread]);
        self.response = responseToClient;
        [self obtainNewTokenForAuthContext:authContext onComplete:completionHandler];
    });
}

- (void) obtainNewTokenForAuthContext:(PGMAuthenticatedContext*)authContext
                          onComplete:(AuthenticationRequestComplete)completionHandler {
    NSError *error = nil;
    PGMAuthenticatedContext *contextFromStore = [self obtainContextFromStorageForUser:authContext.userIdentityId
                                                                                error:&error];
    if (error) {
        self.response.error = error;
        completionHandler(self.response);
    }
    else {
        if ([authContext.accessToken isEqualToString:contextFromStore.accessToken]) { //token is still the same - call refresh
            NSLog(@"Invalid access token - no new token in keychain...");
            self.clientCompletionHanlder = completionHandler;
            [self requestRefreshTokenForAuthContext:authContext];
        }
        else { //some other process already refreshed user's context - we have new token
            self.response.authContext = contextFromStore;
            completionHandler(self.response);
        }
    }
}

@end
