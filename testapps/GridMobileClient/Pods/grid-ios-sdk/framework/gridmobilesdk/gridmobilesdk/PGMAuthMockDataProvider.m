//
//  PGMAuthMockDataProvider.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/7/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthMockDataProvider.h"
#import "PGMConstants.h"

@implementation PGMAuthMockDataProvider

-(NSData*) provideTokenWithUsername:(NSString*)username
                                    password:(NSString*)password {
    
    if ([username isEqualToString:PGMAuthMockUsername] && [password isEqualToString:PGMAuthMockPassword]) {
        return [self returnTokenData];
    }
    else {
        return [self returnInvlaidCredentialsErrorData];
    }
}

-(NSData*) returnTokenData {
    NSString *authJSONString = [NSString stringWithFormat:@"{\"access_token\":\"%@\",\"refresh_token\":\"%@\",\"expires_in\":\"%ld\"}", PGMAuthMockAccessToken, PGMAuthMockRefreshToken, (long)PGMAuthMockTokenExpiresIn];
    
    return [authJSONString dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData*) returnInvlaidCredentialsErrorData {
    NSString *htmlString = @"<html><head></head><body><h2>Login - PIAPI Sample Login Page</h2></body></html>";
    
    return [htmlString dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData*) provideUserIdentityId {
    
    NSString *userIdJSONString = [NSString stringWithFormat:@"{\"status\":\"success\",\"data\":{\"id\":\"mockUsere4b085221e58ac55\",\"userName\":\"%@\",\"resetPassword\":false,\"identity\":{\"uri\":\"https://int-piapi.stg-openclass.com/v1/piapi-int/identities/%@\",\"id\":\"%@\"},\"createdAt\":\"2014-05-02T21:11:02+0000\",\"updatedAt\":\"2014-11-07T18:50:17+0000\"}}", PGMAuthMockUsername, PGMAuthMockPiUserId, PGMAuthMockPiUserId];
    
    return [userIdJSONString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
