//
//  PGMAuthConnectorSerializer.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthenticatedContext.h"
#import "PGMAuthResponse.h"

@interface PGMAuthConnectorSerializer : NSObject

- (PGMAuthResponse*) deserializeAuthenticationData:(NSData*)data
                                       forResponse:(PGMAuthResponse*)response;

- (PGMAuthResponse*) deserializeUserIdData:(NSData*)data
                               forResponse:(PGMAuthResponse*)response;
@end
