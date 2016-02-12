//
//  PGMClient.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 10/31/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMClient.h"
#import "PGMFactory.h"

@implementation PGMClient

- (instancetype) initWithEnvironmentType:(PGMEnvironmentType)environmentType
                              andOptions:(PGMAuthOptions*)options {
    
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.environment = [PGMFactory createEnvironmentWithType:environmentType];
    self.options = options;
    
    //creating default authenticator
    self.authenticator = [self provideAuthenticatorWithOptions:options];
    
    return self;
}

- (PGMAuthenticator*) provideAuthenticatorWithOptions:(PGMAuthOptions*)options {
    
    return [PGMFactory createAuthenticatorWithEnvironment:self.environment andOptions:options];
}

@end
