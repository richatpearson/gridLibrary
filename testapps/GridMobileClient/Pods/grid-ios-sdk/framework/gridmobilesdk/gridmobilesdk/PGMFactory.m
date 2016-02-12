//
//  PGMFactory.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMFactory.h"

@implementation PGMFactory

+(PGMEnvironment*) createEnvironmentWithType:(PGMEnvironmentType)environmentType {
    return [[PGMEnvironment alloc] initEnvironmentFromType:environmentType];
}

+(PGMAuthenticator*) createAuthenticatorWithEnvironment:(PGMEnvironment*)environment
                                             andOptions:(PGMAuthOptions*)options {
    return [[PGMAuthenticator alloc] initWithEnvironment:environment
                                              andOptions:options];
}

+(PGMClassroom*) createClassroom {
    return [[PGMClassroom alloc] init];
}

@end
