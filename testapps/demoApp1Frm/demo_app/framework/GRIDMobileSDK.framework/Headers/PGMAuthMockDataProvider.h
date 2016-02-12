//
//  PGMAuthMockDataProvider.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/7/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthResponse.h"

@interface PGMAuthMockDataProvider : NSObject

-(NSData*) provideTokenWithUsername:(NSString*)username
                                    password:(NSString*)password;

-(NSData*) provideUserIdentityId;

@end
