//
//  PGMConsentSerializer.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthResponse.h"

@interface PGMConsentSerializer : NSObject

- (PGMAuthResponse*) deserializeConsentPoliciesData:(NSData*)data
                                        forResponse:(PGMAuthResponse*)response;

- (PGMAuthResponse*) deserializePostedConsentPoliciesData:(NSData*)data
                                              forResponse:(PGMAuthResponse*)response;

@end
