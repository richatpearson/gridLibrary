//
//  PGMAuthResponse.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMError.h"
#import "PGMAuthenticatedContext.h"

@interface PGMAuthResponse : NSObject

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) PGMAuthenticatedContext *authContext;
@property (nonatomic, strong) NSString *escrowTicket;
@property (nonatomic, strong) NSArray *consentPolicies;

@end
