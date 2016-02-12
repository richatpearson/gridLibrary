//
//  PGMAuthFactory.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/6/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthConnector.h"
#import "PGMAuthConnectorSerializer.h"
#import "PGMAuthMockDataProvider.h"
#import "PGMCoreNetworkRequester.h"
#import "PGMAuthKeychainStorageManager.h"
#import "PGMConsentConnector.h"
#import "PGMConsentSerializer.h"
#import "PGMConsentConnector.h"

@interface PGMAuthFactory : NSObject

+(PGMAuthConnector*) createAuthConnectorWithEnvironment:(PGMEnvironment*)environment
                                       andClientOptions:(PGMAuthOptions*)options;

+(PGMAuthConnectorSerializer*) createAuthConnectorSerializer;
+(PGMAuthMockDataProvider*) createAuthMockDataProvider;
+(PGMCoreNetworkRequester*) createCoreNetworkRequester;
+(PGMAuthKeychainStorageManager*) createAuthKeychainStorageManager;
+(PGMConsentConnector*) createConsentConnectorWithEnvironment:(PGMEnvironment*)environment;
+(PGMConsentSerializer*) createConsentSerializer;

@end
