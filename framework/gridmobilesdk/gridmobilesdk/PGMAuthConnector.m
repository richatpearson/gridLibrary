//
//  PGMAuthenticatorConnector.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthConnector.h"
#import "PGMAuthFactory.h"

@interface PGMAuthConnector()

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) PGMAuthResponse *authResponse;
@property (nonatomic, strong) NSString *username;

@end

NSTimeInterval const PGMAuthTimeout = 10.0;

@implementation PGMAuthConnector

-(instancetype) initWithEnvironment:(PGMEnvironment*)environment
                   andClientOptions:(PGMAuthOptions*)options {
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    if (environment) {
        self.environment = environment;
    }
    
    if (options) {
        self.clientOptions = options;
    }
    
    [self setCoreNetworkRequester:[PGMAuthFactory createCoreNetworkRequester]];
    [self setConnectorSerializer:[PGMAuthFactory createAuthConnectorSerializer]];
    [self setMockDataProvider:[PGMAuthFactory createAuthMockDataProvider]];
    
    return self;
}

-(void) setCoreNetworkRequester:(PGMCoreNetworkRequester*)networkRequester {
    self.networkRequester = networkRequester;
}

-(void) setConnectorSerializer:(PGMAuthConnectorSerializer*)connectorSerializer {
    self.authConnectorSerilizer = connectorSerializer;
}

-(void) setMockDataProvider:(PGMAuthMockDataProvider*)mockDataProvider {
    self.authMockDataProvider = mockDataProvider;
}

-(void) runAuthenticationRequestWithUsername:(NSString*)username
                                    password:(NSString*)password
                                 andResponse:(PGMAuthResponse*)response
                                  onComplete:(AuthConnectorRequestComplete)completionHandler {
    if (!response) {
        response = [PGMAuthResponse new];
    }
    
    self.authResponse = response;
    self.username = username;
    
    if (![self validateAuthenticationArguments]) {
        //NSLog(@"Missing arguments - will exec onComplete");
        self.authResponse.error = self.error;
        completionHandler(self.authResponse);
        return;
    }
    
    [self executeAuthRequestForUsername:username andPassword:password onComplete:completionHandler];
}

- (BOOL) validateAuthenticationArguments
{
    if ((!self.environment) || self.environment.currentEnvironment == PGMNoEnvironment)
    {
        NSString *errorDesc = @"Missing environment.";
        
        self.error = [PGMError createErrorForErrorCode:PGMAuthenticationError
                                        andDescription:errorDesc];
        return NO;
    }
    
    if (((!self.clientOptions) || (!self.clientOptions.clientId) || [self.clientOptions.clientId isEqualToString:@""]
        || (!self.clientOptions.clientSecret) || [self.clientOptions.clientSecret isEqualToString:@""]
        || (!self.clientOptions.redirectUrl) || [self.clientOptions.redirectUrl isEqualToString:@""]) &&
        self.environment.currentEnvironment != PGMSimulatedEnv)
    {
        NSString *errorDesc = @"One or more client options missing. Please provide client id, client secret and redirect url for Pi authentication";
        
        self.error = [PGMError createErrorForErrorCode:PGMAuthenticationError
                                        andDescription:errorDesc];
        return NO;
    }
    
    return YES;
}

-(void) executeAuthRequestForUsername:(NSString*)username
                          andPassword:(NSString*)password
                           onComplete:(AuthConnectorRequestComplete)onCompleteHandler {
    
    if (self.environment.currentEnvironment == PGMSimulatedEnv) {
        NSData *mockData = [self.authMockDataProvider provideTokenWithUsername:username password:password];
        [self parseAuthResultForData:mockData];
        onCompleteHandler(self.authResponse);
    }
    else {
        NSURLRequest *loginRequest = [self buildNetworkRequestForLoginWithUsername:username andPassword:password];
        
        NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
            if (error && !data) {
                self.authResponse.error = error;
                onCompleteHandler(self.authResponse);
            }
            else {
                [self parseAuthResultForData:data];
                (self.authResponse.authContext) ? NSLog(@"Access token from context is: %@", self.authResponse.authContext.accessToken) : NSLog(@"No auth context");
                onCompleteHandler(self.authResponse);
                return;
            }
        };
        
        [self.networkRequester performNetworkCallWithRequest:loginRequest
                                        andCompletionHandler:networkingCompletionHandler];
    }
}

-(void) parseAuthResultForData:(NSData*)data {
    self.authResponse = [self.authConnectorSerilizer deserializeAuthenticationData:data
                                                                       forResponse:self.authResponse];
    if (self.authResponse.authContext && self.authResponse.authContext.accessToken) {
        [self storeCredentialsInResponseForUsername:self.username]; //self.username may be nil for refresh flow
    }
}

-(void) runUserIdRequestWithResponse:(PGMAuthResponse*)response
                          onComplete:(AuthConnectorRequestComplete)completionHandler {
    self.authResponse = response;
    
    if (![self validateUserIdArguments]) {
        NSLog(@"Missing User id arguments - will exec onComplete");
        if (!self.authResponse) {
            self.authResponse = [PGMAuthResponse new]; //needed only if this method is called outside of login process
        }
        self.authResponse.error = self.error;
        completionHandler(self.authResponse);
        return;
    }
    
    self.username = response.authContext.username;
    
    [self executeUserIdRequestWithOnComplete:completionHandler];
}

- (BOOL) validateUserIdArguments
{
    if (!self.authResponse || !self.authResponse.authContext) {
        self.error = [PGMError createErrorForErrorCode:PGMAuthUserIdError
                                        andDescription:@"Missing authenticated context for user Id request"];
        return NO;
    }
    
    if (!self.authResponse.authContext.accessToken || [self.authResponse.authContext.accessToken isEqualToString:@""]
        || !self.authResponse.authContext.username || [self.authResponse.authContext.username isEqualToString:@""]) {
        
        self.error = [PGMError createErrorForErrorCode:PGMAuthUserIdError
                                        andDescription:@"Username and access token are required for user Id request"];
        return NO;
    }
    
    return YES;
}

-(void) executeUserIdRequestWithOnComplete:(AuthConnectorRequestComplete)onCompletHandler {
    if (self.environment.currentEnvironment == PGMSimulatedEnv) {
        NSData *mockData = [self.authMockDataProvider provideUserIdentityId];
        [self parseUserIdResultForData:mockData];
        onCompletHandler(self.authResponse);
    }
    else {
        NSURLRequest *userIdRequest = [self buildNetworkRequestForUserIdWithToken:self.authResponse.authContext.accessToken];
        //__weak PGMAuthConnector *weakself = self; //not sure we need it...unless this class has a strong ref to this block (property)
        NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
            if (error && !data) { //in case when we have 404 and data returned - we want the parsers to determine the correct error scenario, like no user consent
                self.authResponse.error = error;
                [self removeAuthContextOnErrorFromResponse];
                onCompletHandler(self.authResponse);
            }
            else {
                [self parseUserIdResultForData:data];
                (self.authResponse.authContext) ? NSLog(@"User id is %@", self.authResponse.authContext.userIdentityId) : NSLog(@"Nil authContext");
                onCompletHandler(self.authResponse);
            }
        };
        
        [self.networkRequester performNetworkCallWithRequest:userIdRequest
                                        andCompletionHandler:networkingCompletionHandler];
    }
}

-(void) removeAuthContextOnErrorFromResponse {
    if (self.authResponse.error) {
        self.authResponse.authContext = nil; //don't want to return partial auth context if error with user id data
    }
}

-(void) parseUserIdResultForData:(NSData*) data {
    self.authResponse = [self.authConnectorSerilizer deserializeUserIdData:data
                                                               forResponse:self.authResponse];
    [self removeAuthContextOnErrorFromResponse];
}

-(void) storeCredentialsInResponseForUsername:(NSString*)username {
    self.authResponse.authContext.username = username;
    //self.authResponse.authContext.password = password;
}

-(NSURLRequest*) buildNetworkRequestForLoginWithUsername:(NSString*)username
                                             andPassword:(NSString*)password {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@", self.environment.PGMAuthBase, PGMAuthLoginLocalPath];
    NSLog(@"URL for login is: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableString *postString = [NSMutableString stringWithFormat:@"%@=%@", PGMAuthUsernameKey, username];
    [postString appendFormat:@"&%@=%@", PGMAuthPasswordKey, password];
    [postString appendFormat:@"&%@=%@", PGMAuthSuccessUrlKey, self.environment.PGMAuthLoginSuccessUrl];
    [postString appendFormat:@"&%@=%@", PGMAuthRedirectUrlKey, self.clientOptions.redirectUrl];
    [postString appendFormat:@"&%@=%@", PGMAuthResponseTypeKey, PGMAuthResponseType];
    [postString appendFormat:@"&%@=%@", PGMAuthScopeKey, PGMAuthScope];
    [postString appendFormat:@"&%@=%@", PGMAuthClientIdKey, self.clientOptions.clientId];
    NSLog(@"postString: %@", postString);
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

-(NSURLRequest*) buildNetworkRequestForUserIdWithToken:(NSString*)token {
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@%@", self.environment.PGMAuthBase, PGMAuthUseridLocalPath, self.username];
    NSLog(@"Url for user id is: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthTimeout];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    
    return request;
}

-(void) runRefreshTokenWithResponse:(PGMAuthResponse*)response
                        authContext:(PGMAuthenticatedContext*)authContext
                         onComplete:(AuthenticationRequestComplete)completionHandler {
    if (!response) {
        response = [PGMAuthResponse new];
    }
    
    self.authResponse = response;
    
    if ([self isRefreshTokenEmpty:authContext.refreshToken]) {
        response.error = self.error;
        completionHandler(response);
        return;
    }
    
    if (![self validateAuthenticationArguments]) {
        self.authResponse.error = self.error;
        completionHandler(self.authResponse);
        return;
    }
    
    [self executeRefreshTokenWithAuthContext:authContext onComplete:completionHandler];
}

-(BOOL) isRefreshTokenEmpty:(NSString*)refreshToken {
    if (!refreshToken || [refreshToken isEqualToString:@""]) {
        self.error = [PGMError createErrorForErrorCode:PGMAuthMissingRefreshTokenError
                                        andDescription:@"Missing refresh token from context - please login again."];
        return YES;
    }
    return NO;
}

-(void) executeRefreshTokenWithAuthContext:(PGMAuthenticatedContext*)authContext
                             onComplete:(AuthenticationRequestComplete)completionHandler {
    
    NSURLRequest *loginRequest = [self buildNetworkRequestForRefreshToken:authContext.refreshToken];
    
    NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
        if (error && !data) {
            self.authResponse.error = error;
            completionHandler(self.authResponse);
        }
        else {
            [self parseAuthResultForData:data];
            (self.authResponse.authContext) ? NSLog(@"Access token from context after refresh is: %@", self.authResponse.authContext.accessToken) : NSLog(@"No auth context");
            completionHandler(self.authResponse);
            return;
        }
    };
    
    [self.networkRequester performNetworkCallWithRequest:loginRequest
                                    andCompletionHandler:networkingCompletionHandler];
}

-(NSURLRequest*) buildNetworkRequestForRefreshToken:(NSString*)refreshToken {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@", self.environment.authRefreshTokenBase, PGMAuthRefreshTokenLocalPath];
    NSLog(@"URL for refresh token is: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSString *postString = [NSString stringWithFormat:@"%@=%@", PGMAuthRefreshTokenBodyKey, refreshToken];
    NSLog(@"postString: %@", postString);
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthTimeout];
    
    NSString *clientCreds = [NSString stringWithFormat:@"%@:%@", self.clientOptions.clientId, self.clientOptions.clientSecret];
    NSString *authString = [[clientCreds dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    authString = [NSString stringWithFormat:@"Basic %@", authString];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    return request;
}

#pragma mark forgot username/password
-(void) runForgotUsernameForEmail:(NSString *)email
                     withResponse:(PGMAuthResponse*)response
                       onComplete:(AuthenticationRequestComplete)completionHandler {
    if (!response) {
        response = [PGMAuthResponse new];
    }
    
    self.authResponse = response;
    
    NSURLRequest *forgotUsernameRequest = [self buildNetworkRequestForForgotUsernameForEmail:email];
    
    NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
        if (error && !data) {
            response.error = error;
            completionHandler(response);
        }
        else {
            if (error) { //non-200 response - need to parse error msg from Pi
                NSLog(@"Forgot username got error - need to parse...");
                [self parseForgotUsernameForData:data withRresponse:(PGMAuthResponse*)self.authResponse];
            }
            completionHandler(response);
            return;
        }
    };
    
    [self.networkRequester performNetworkCallWithRequest:forgotUsernameRequest
                                    andCompletionHandler:networkingCompletionHandler];
}


-(NSURLRequest*) buildNetworkRequestForForgotUsernameForEmail:(NSString *)email {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@", self.environment.PGMAuthBase, PGMAuthForgotUsername];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableString *postString = [NSMutableString stringWithFormat:@"emailaddress=%@", email];
    [postString appendFormat:@"&client_id=%@", self.clientOptions.clientId];
    
    NSLog(@"URL for forgot username is: %@ and post string: %@", stringUrl, postString);
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    return request;
}

-(void) parseForgotUsernameForData:(NSData*)data
                     withRresponse:(PGMAuthResponse*)response {
    self.authResponse = [self.authConnectorSerilizer deserializeForgotUsernameData:data forResponse:response];
}

-(void) runForgotPasswordForUsername:(NSString *)username
                        withResponse:(PGMAuthResponse*)response
                          onComplete:(AuthenticationRequestComplete)completionHandler {
    if (!response) {
        response = [PGMAuthResponse new];
    }
    
    self.authResponse = response;
    NSURLRequest *forgotPasswordRequest = [self buildNetworkRequestForForgotPasswordForUsername:username];
    
    NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
        if (error && !data) {
            response.error = error;
            completionHandler(response);
        }
        else {
            if (error) { //non-200 response - need to parse error msg from Pi
                NSLog(@"Forgot password got error - need to parse...");
                [self parseForgotPasswordForData:data
                                   withRresponse:(PGMAuthResponse*)self.authResponse];
            }
            completionHandler(response);
            return;
        }
    };
    
    [self.networkRequester performNetworkCallWithRequest:forgotPasswordRequest
                                    andCompletionHandler:networkingCompletionHandler];
}

-(NSURLRequest*) buildNetworkRequestForForgotPasswordForUsername:(NSString *)username {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@", self.environment.PGMAuthBase, PGMAuthForgotPassword];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableString *postString = [NSMutableString stringWithFormat:@"username=%@", username];
    [postString appendFormat:@"&client_id=%@", self.clientOptions.clientId];
    
    NSLog(@"URL for forgot password is: %@ and post string: %@", stringUrl, postString);
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    return request;
}

-(void) parseForgotPasswordForData:(NSData*)data
                     withRresponse:(PGMAuthResponse*)response {
    self.authResponse = [self.authConnectorSerilizer deserializeForgotPasswordData:data
                                                                       forResponse:response];
}

@end
