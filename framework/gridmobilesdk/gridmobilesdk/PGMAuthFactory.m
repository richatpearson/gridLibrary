//
//  PGMAuthFactory.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/6/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthFactory.h"

@implementation PGMAuthFactory

+(PGMAuthConnector*) createAuthConnectorWithEnvironment:(PGMEnvironment*)environment
                                       andClientOptions:(PGMAuthOptions*)options {
    return [[PGMAuthConnector alloc] initWithEnvironment:environment andClientOptions:options];
}

+(PGMAuthConnectorSerializer*) createAuthConnectorSerializer {
    return [PGMAuthConnectorSerializer new];
}

+(PGMAuthMockDataProvider*) createAuthMockDataProvider {
    return [PGMAuthMockDataProvider new];
}

+(PGMCoreNetworkRequester*) createCoreNetworkRequester {
    return [PGMCoreNetworkRequester new];
}

+(PGMAuthKeychainStorageManager*) createAuthKeychainStorageManager {
    return [PGMAuthKeychainStorageManager new];
}

+(PGMConsentConnector*) createConsentConnectorWithEnvironment:(PGMEnvironment*)environment {
    return [[PGMConsentConnector alloc] initWithEnvironment:environment];
}

+(PGMConsentSerializer*) createConsentSerializer {
    return [PGMConsentSerializer new];
}

@end
