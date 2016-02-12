//
//  PGMAuthenticatorConnector.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthResponse.h"
#import "PGMEnvironment.h"
#import "PGMAuthOptions.h"
#import "PGMAuthResponse.h"
#import "PGMAuthConnectorSerializer.h"
#import "PGMAuthMockDataProvider.h"
#import "PGMCoreNetworkRequester.h"

//@class PGMAuthenticator;
typedef void (^AuthenticationRequestComplete)(PGMAuthResponse *response); //this is app's completion hanlder
typedef void (^AuthConnectorRequestComplete)(PGMAuthResponse *response); //this is authenticator's completion handler when calling auth connector

@interface PGMAuthConnector : NSObject

@property (nonatomic, strong) PGMEnvironment *environment;
@property (nonatomic, strong) PGMAuthOptions *clientOptions;

@property (nonatomic, strong) PGMAuthConnectorSerializer *authConnectorSerilizer;
@property (nonatomic, strong) PGMAuthMockDataProvider *authMockDataProvider;
@property (nonatomic, strong) PGMCoreNetworkRequester *networkRequester;

-(instancetype) initWithEnvironment:(PGMEnvironment*)environment
                   andClientOptions:(PGMAuthOptions*)options;

-(void) setCoreNetworkRequester:(PGMCoreNetworkRequester*)networkRequester;
-(void) setConnectorSerializer:(PGMAuthConnectorSerializer*)connectorSerializer;
-(void) setMockDataProvider:(PGMAuthMockDataProvider*)mockDataProvider;

-(void) runAuthenticationRequestWithUsername:(NSString*)username
                                    password:(NSString*)password
                                 andResponse:(PGMAuthResponse*)response
                                  onComplete:(AuthConnectorRequestComplete)completionHandler;

-(void) runUserIdRequestWithResponse:(PGMAuthResponse*)response
                          onComplete:(AuthConnectorRequestComplete)completionHandler;

-(void) runRefreshTokenWithResponse:(PGMAuthResponse*)response
                        authContext:(PGMAuthenticatedContext*)authContext
                         onComplete:(AuthenticationRequestComplete)completionHandler;

@end
