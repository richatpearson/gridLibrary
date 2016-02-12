//
//  PGMEnvironment.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMEnvironment.h"

@implementation PGMEnvironment

-(instancetype) initEnvironmentFromType:(PGMEnvironmentType)type {
    
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.currentEnvironment = type;
    [self setEnvironmentBaseUrls];
    
    return self;
}

- (void) setEnvironmentBaseUrls {
    switch (self.currentEnvironment) {
        case PGMStagingEnv:
            self.PGMAuthBase = PGMAuthBase_Staging;
            self.PGMAuthLoginSuccessUrl = PGMAuthLoginSuccessUrl_Staging;
            self.PGMAuthEscrowBase = PGMAuthEscrowBase_Staging;
            self.authRefreshTokenBase = PGMAuthRefreshTokenBase_Staging;
            break;
        case PGMProductionEnv:
            self.PGMAuthBase = PGMAuthBase_Prod;
            self.PGMAuthLoginSuccessUrl = PGMAuthLoginSuccessUrl_Prod;
            self.PGMAuthEscrowBase = PGMAuthEscrowBase_Prod;
            self.authRefreshTokenBase = PGMAuthRefreshTokenBase_Prod;
            break;
        default:
            break;
    }
}

@end
