//
//  PGMAuthConnectorSerializer.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthConnectorSerializer.h"
#import "PGMConstants.h"

@interface PGMAuthConnectorSerializer()

@property (nonatomic, strong) NSDictionary *authDataDict;
@property (nonatomic, strong) NSError *authError;

@end

@implementation PGMAuthConnectorSerializer

- (PGMAuthResponse*) deserializeAuthenticationData:(NSData*)data
                                       forResponse:(PGMAuthResponse*)response {
    if (!data)
    {
        response.error =
            [PGMError createErrorForErrorCode:PGMAuthenticationError andDescription:@"Pi login API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    NSLog(@"JSON from Pi Authentication is: %@:::error: %@", self.authDataDict, self.authError);
    
    if (self.authError) {
        return [self parseAuthErrorsForResponse:response];
    }
    
    if ([self.authDataDict objectForKey:@"access_token"]) {
        PGMAuthenticatedContext *authContext =
        [[PGMAuthenticatedContext alloc] initWithAccessToken:[self.authDataDict objectForKey:@"access_token"]
                                                RefreshToken:[self.authDataDict objectForKey:@"refresh_token"]
                                       andExpirationInterval:(NSUInteger)[[self.authDataDict objectForKey:@"expires_in"] integerValue]];
        
        response.authContext = authContext;
        
        return response;
    }
    else {
        return [self parseAuthErrorsForResponse:response];
    }
}

-(void) deserializeData:(NSData*)data {
    NSError *jsonError = nil;
    self.authDataDict = nil;
    self.authDataDict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data
                                                                       options:kNilOptions
                                                                         error:&jsonError];
    self.authError = jsonError;
}

-(PGMAuthResponse*) parseAuthErrorsForResponse:(PGMAuthResponse*)response {
    if (self.authError) {
        if (self.authError.code == 3840) { //invalid creds
            response.error = [PGMError createErrorForErrorCode:PGMAuthInvalidCredentialsError
                                                andDescription:@"Invalid username or password"];
        }
    }
    else {
        if ([self.authDataDict objectForKey:@"code"])
        {
            // User consent needed
            if ([[self.authDataDict objectForKey:@"code"] isEqualToString:@"403-FORBIDDEN"])
            {
                if (![self.authDataDict objectForKey:@"message"] ||
                    [[self.authDataDict objectForKey:@"message"] isEqualToString:@""]) {
                    
                    NSString *errorDesc = @"User consent needed but consent ticket not found in auth response.";
                    response.error = [PGMError createErrorForErrorCode:PGMAuthenticationError andDescription:errorDesc];
                    
                }
                else {
                    response.error =
                      [PGMError createErrorForErrorCode:PGMAuthNoConsentError andDescription: @"User missing consent"];
                    response.escrowTicket = [self.authDataDict objectForKey:@"message"];
                }
            }
            if ([[self.authDataDict objectForKey:@"code"] isEqualToString:@"404-NOT_FOUND"]) //user failed to express consent at least 10 times
            {
                response.error = [PGMError createErrorForErrorCode:PGMAuthMaxRefuseConsentError
                                                    andDescription:@"Max number of login attempts with missing consent reached."];
            }
            if ([[self.authDataDict objectForKey:@"code"] isEqualToString:@"401"] &&
                [[self.authDataDict objectForKey:@"message"] isEqualToString:@"Invalid client Id"]) { //invalid client id
                
                response.error = [PGMError createErrorForErrorCode:PGMAuthInvalidClientId andDescription:@"Invalid client Id"];
            }
        }
        else if ([[self.authDataDict objectForKey:@"Error"] isEqualToString:@"Invalid Refresh Token"]) { //refresh token expired
            NSString *errorDesc = @"Expired refresh token - please login again.";
            response.error = [PGMError createErrorForErrorCode:PGMAuthRefreshTokenExpiredError andDescription:errorDesc];
        }
    }
    
    return response;
}

-(PGMAuthResponse*) deserializeUserIdData:(NSData *)data
                             forResponse :(PGMAuthResponse *)response {
    if (!data)
    {
        response.error =
        [PGMError createErrorForErrorCode:PGMAuthenticationError andDescription:@"Pi User id API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    NSLog(@"JSON from Pi User id call is: %@:::error: %@", self.authDataDict, self.authError);
    
    if (self.authError) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthenticationError andDescription:@"Cannot deserialize user id data"];
        return response;
    }
    
    NSString *identityId = [[[self.authDataDict objectForKey:@"data"] objectForKey:@"identity"] objectForKey:@"id"];
    if (!response.authContext) {
        response.authContext = [PGMAuthenticatedContext new];
    }
    response.authContext.userIdentityId = identityId;
    
    return response;
}

- (PGMAuthResponse*) deserializeForgotUsernameData:(NSData*)data
                                       forResponse:(PGMAuthResponse*)response {
    if (!data)
    {
        response.error =
        [PGMError createErrorForErrorCode:PGMAuthenticationError
                           andDescription:@"Pi Forgot Username API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    if (self.authError) {
        //do nothing - we got an HTML, which actually is a success
    }
    else { //we got JSON with an error - need to parse
        NSLog(@"Error JSON is: %@", self.authDataDict.description);
        
        if ([[self.authDataDict objectForKey:@"status"] isEqualToString:@"error"]) {
            NSString *errorCode = [[[self.authDataDict objectForKey:@"fault"] objectForKey:@"detail"] objectForKey:@"errorcode"];
            
            if ([errorCode isEqualToString:PGMAuthForgotUsernameEmailNotFound]) {
                response.error =
                    [PGMError createErrorForErrorCode:PGMAuthEmailNotFound
                                       andDescription:@"No such e-mail address found"];
            }
            else {
                response.error =
                    [PGMError createErrorForErrorCode:PGMAuthUnknownForgotUsernameError
                                       andDescription:@"Unknown error while calling Forgot Username. Please try again later"];
            }
        }
    }
    
    return response;
}

- (PGMAuthResponse*) deserializeForgotPasswordData:(NSData*)data
                                       forResponse:(PGMAuthResponse*)response{
    if (!data)
    {
        response.error =
        [PGMError createErrorForErrorCode:PGMAuthenticationError
                           andDescription:@"Pi Forgot Password API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    if (self.authError) {
        //do nothing - we got an HTML, which actually is a success
    }
    else { //we got JSON with an error - need to parse
        NSLog(@"Error JSON is: %@", self.authDataDict.description);
        
        if ([[self.authDataDict objectForKey:@"status"] isEqualToString:@"error"]) {
            NSString *errorCode = [[[self.authDataDict objectForKey:@"fault"] objectForKey:@"detail"] objectForKey:@"errorcode"];
            
            if ([errorCode isEqualToString:PGMAuthForgotPasswordNoSuchUsername]) {
                response.error =
                [PGMError createErrorForErrorCode:PGMAuthUsernameNotFoundError andDescription:@"No such username found"];
            }
            else if ([errorCode isEqualToString:PGMAuthForgotPasswordTooManyTickets]) { //User tried too many times w/out resetting the password
                NSString *errorMsg = @"User exceeded max number of requesting password reset w/out actually resetting the password. Please contact system administrator.";
                response.error =
                [PGMError createErrorForErrorCode:PGMAuthMaxForgotPasswordExceededError
                                   andDescription:errorMsg];
            }
            else { //unknown error
                response.error =
                [PGMError createErrorForErrorCode:PGMAuthUnknownForgotPasswordError
                                   andDescription:@"Unknown error while calling Forgot Password. Please try again later"];
            }
        }
    }
    
    return response;
}

@end
