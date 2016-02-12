//
//  PGMContext.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthenticatedContext.h"

@interface PGMAuthenticatedContext()

@property (nonatomic, readwrite) NSString *accessToken;
@property (nonatomic, readwrite) NSString *refreshToken;
@property (nonatomic, readwrite, assign) NSInteger tokenExpiresIn;
@property (nonatomic, readwrite) NSTimeInterval creationDateInterval;

@end

@implementation PGMAuthenticatedContext

-(instancetype) initWithAccessToken:(NSString*)token
                       RefreshToken:(NSString*)refreshToken
              andExpirationInterval:(NSUInteger)expiresIn {
    self = [super init];
    if (self)
    {
        self.accessToken = token;
        self.refreshToken = refreshToken;
        self.tokenExpiresIn = expiresIn;
        self.creationDateInterval = [[NSDate date] timeIntervalSince1970];
    }
    
    return  self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
    self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
    self.tokenExpiresIn = [decoder decodeIntegerForKey:@"expiresIn"];
    self.creationDateInterval = [decoder decodeDoubleForKey:@"creationDateInterval"];
    self.userIdentityId = [decoder decodeObjectForKey:@"userIdentityId"];
    self.username = [decoder decodeObjectForKey:@"username"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeInteger:self.tokenExpiresIn forKey:@"expiresIn"];
    [encoder encodeDouble:self.creationDateInterval forKey:@"creationDateInterval"];
    [encoder encodeObject:self.userIdentityId forKey:@"userIdentityId"];
    [encoder encodeObject:self.username forKey:@"username"];
}

-(BOOL) isTokenCurrent {
    if (self.tokenExpiresIn)
    {
        NSTimeInterval currentDateInterval = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"currentDateInterval: %f", currentDateInterval);
        NSLog(@"creationDateInterval: %f", self.creationDateInterval);
        NSLog(@"Difference: %f", (currentDateInterval - self.creationDateInterval));
        NSLog(@"isExpired interval in seconds is: %ld", (long)self.tokenExpiresIn);
        
        if( (currentDateInterval - self.creationDateInterval) > self.tokenExpiresIn )
        {
            NSLog(@"Token expired");
            return NO;
        }
        
        return YES;
    }
    return NO;
}

@end
