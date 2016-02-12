//
//  PGMFactory.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthenticator.h"
#import "PGMAuthOptions.h"
#import "PGMClassroom.h"
#import "PGMEnvironment.h"

@interface PGMFactory : NSObject

+(PGMEnvironment*) createEnvironmentWithType:(PGMEnvironmentType)environmentType;
+(PGMAuthenticator*) createAuthenticatorWithEnvironment:(PGMEnvironment*)environment
                                                andOptions:(PGMAuthOptions*)options;
+(PGMClassroom*) createClassroom;

@end
