//
//  PGMAuthTokenValidator.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/29/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthConnector.h"
#import "PGMAuthKeychainStorageManager.h"

@interface PGMAuthContextValidator : NSObject
{
    dispatch_queue_t serialQueue;
    dispatch_semaphore_t semaphore;
}

@property (nonatomic, strong) PGMAuthKeychainStorageManager *keychainStorageManager;
@property (nonatomic, strong) PGMAuthConnector *authConnector;

-(instancetype) init;

-(void) provideCurrentContextForUser:(NSString*)userId
                         environment:(PGMEnvironment*)environment
                             options:(PGMAuthOptions*)userOptions
                          onComplete:(AuthenticationRequestComplete)completionHandler;

-(void) provideCurrentTokenForAuthContext:(PGMAuthenticatedContext*)authContext
                              environment:(PGMEnvironment*)environment
                                  options:(PGMAuthOptions*)userOptions
                               onComplete:(AuthenticationRequestComplete)completionHandler;

@end
