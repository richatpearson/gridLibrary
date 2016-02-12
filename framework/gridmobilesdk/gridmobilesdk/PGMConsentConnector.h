//
//  PGMConsentConnector.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMEnvironment.h"
#import "PGMCoreNetworkRequester.h"
#import "PGMConsentSerializer.h"
#import "PGMAuthResponse.h"
#import "PGMAuthConnector.h"

@interface PGMConsentConnector : NSObject

@property (nonatomic, strong) PGMEnvironment *environment;

@property (nonatomic, strong) PGMConsentSerializer *consentSerializer;
@property (nonatomic, strong) PGMCoreNetworkRequester *networkRequester;

-(instancetype) initWithEnvironment:(PGMEnvironment*)environment;

-(void) setCoreNetworkRequester:(PGMCoreNetworkRequester*)networkRequester;
-(void) setConsentSerializer:(PGMConsentSerializer *)consentSerializer;

-(void) runPoliciesRequestWithEscrowTicket:(NSString*)escrowTicket
                               forResponse:(PGMAuthResponse*)response
                                OnComplete:(AuthenticationRequestComplete)onCompletHandler;

-(void) runConsentSubmissionForPolicyIds:(NSArray*)policies
                            escrowTicket:(NSString*)escrowTicket
                                response:(PGMAuthResponse*)response
                              onComplete:(AuthenticationRequestComplete)onComplete;

@end
