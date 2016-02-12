//
//  PGMClient.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 10/31/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMEnvironment.h"
#import "PGMAuthenticator.h"
#import "PGMAuthOptions.h"

@interface PGMClient : NSObject

@property (nonatomic, strong) PGMEnvironment *environment;
@property (nonatomic, strong) PGMAuthOptions *options;
@property (nonatomic, strong) PGMAuthenticator *authenticator;

- (instancetype) initWithEnvironmentType:(PGMEnvironmentType)environmentType
                              andOptions:(PGMAuthOptions*)options;

@end
