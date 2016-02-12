//
//  PGMContext.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMAuthenticatedContext : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *refreshToken;
@property (nonatomic, readonly, assign) NSInteger tokenExpiresIn;
@property (nonatomic, readonly) NSTimeInterval creationDateInterval;
@property (nonatomic, strong) NSString *userIdentityId;
@property (nonatomic, strong) NSString *username;

-(instancetype) initWithAccessToken:(NSString*)token
                       RefreshToken:(NSString*)refreshToken
              andExpirationInterval:(NSUInteger)expiresIn;

-(BOOL) isTokenCurrent;

@end
