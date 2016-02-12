//
//  PGMEnvironment.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMConstants.h"

typedef NS_ENUM(NSInteger, PGMEnvironmentType) {
    PGMNoEnvironment    = -1,
    PGMStagingEnv       = 0,
    PGMProductionEnv    = 1,
    PGMCustomEnv        = 2,
    PGMSimulatedEnv     = 3
};

@interface PGMEnvironment : NSObject

-(instancetype) initEnvironmentFromType:(PGMEnvironmentType)type;

@property (nonatomic, assign) PGMEnvironmentType currentEnvironment;
@property (nonatomic, strong) NSString *PGMAuthBase;
@property (nonatomic, strong) NSString *PGMAuthEscrowBase;
@property (nonatomic, strong) NSString *PGMAuthLoginSuccessUrl;
@property (nonatomic, strong) NSString *authRefreshTokenBase;

@end
