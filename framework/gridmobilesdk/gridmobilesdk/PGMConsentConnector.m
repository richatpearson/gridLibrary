//
//  PGMConsentConnector.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMConsentConnector.h"
#import "PGMAuthFactory.h"
#import "PGMConsentPolicy.h"

@interface PGMConsentConnector()

@property (nonatomic, strong) PGMAuthResponse *authResponse;

@end

NSTimeInterval const PGMAuthEscrowTimeout = 10.0;

@implementation PGMConsentConnector

-(instancetype) initWithEnvironment:(PGMEnvironment*)environment {
    self = [super init];
    if (self)
    {
        if (environment) {
            self.environment = environment;
        }
        
        [self setCoreNetworkRequester:[PGMAuthFactory createCoreNetworkRequester]];
        //[self setConsentSerilizer:[PGMAuthFactory createConsentSerializer]];
        self.consentSerializer = [PGMAuthFactory createConsentSerializer];
    }
    
    return self;
}

-(void) setCoreNetworkRequester:(PGMCoreNetworkRequester*)networkRequester {
    self.networkRequester = networkRequester;
}

/*-(void) setConsentSerilizer:(PGMConsentSerializer *)consentSerilizer {
    self.consentSerilizer = consentSerilizer;
}*/



-(void) runPoliciesRequestWithEscrowTicket:(NSString*)escrowTicket
                               forResponse:(PGMAuthResponse*)response
                                OnComplete:(AuthenticationRequestComplete)onCompletHandler {
    self.authResponse = response;
    
    [self executePoliciesRequestForEscrowTicket:escrowTicket OnComplete:onCompletHandler];
}

-(void) executePoliciesRequestForEscrowTicket:(NSString*)escrowTicket
                                   OnComplete:(AuthenticationRequestComplete)onCompletHandler {
    
    NSURLRequest *requestForConsentPolicies = [self buildNetworkRequestForConsentPoliciesWithEscrowTicket:escrowTicket];
    
    NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
        NSLog(@"Networking onComplete for consent policies...");
        if (error && !data) {
            self.authResponse.error = error;
            onCompletHandler(self.authResponse);
        }
        else {
            [self parseConsentPoliciesResultForData:data];
            (self.authResponse.consentPolicies) ? NSLog(@"User has %lu policies to consent to.", (unsigned long)self.authResponse.consentPolicies.count) : NSLog(@"No consent policies for user.");
            onCompletHandler(self.authResponse);
        }
    };
    
    [self.networkRequester performNetworkCallWithRequest:requestForConsentPolicies
                                    andCompletionHandler:networkingCompletionHandler];
}


-(NSURLRequest*) buildNetworkRequestForConsentPoliciesWithEscrowTicket:(NSString*)escrowTicket {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@%@", self.environment.PGMAuthEscrowBase,
                           PGMAuthEscrowPoliciesLocalPath, escrowTicket];
    NSLog(@"Url for getting user consent policies is: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthEscrowTimeout];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

-(void) parseConsentPoliciesResultForData:(NSData*)data {
    self.authResponse = [self.consentSerializer deserializeConsentPoliciesData:data forResponse:self.authResponse];
}

-(void) runConsentSubmissionForPolicyIds:(NSArray*)policies
                            escrowTicket:(NSString*)escrowTicket
                                response:(PGMAuthResponse*)response
                              onComplete:(AuthenticationRequestComplete)onComplete {
    self.authResponse = response;
    
    [self executeConsentSubmissionForPolicyIds:policies escrowTicket:escrowTicket response:response onComplete:onComplete];
}

-(void) executeConsentSubmissionForPolicyIds:(NSArray*)policies
                                escrowTicket:(NSString*)escrowTicket
                                    response:(PGMAuthResponse*)response
                                  onComplete:(AuthenticationRequestComplete)onCompletHandler {
    
    NSURLRequest *requestToPostConsent = [self buildNetworkRequestForConsentSubmissionForPolicies:policies
                                                                                     escrowTicket:escrowTicket];
    
    NetworkRequestComplete networkingCompletionHandler = ^(NSData* data, NSError *error) {
        NSLog(@"Networking onComplete for posting consent policies...");
        if (error && !data) { //only when no data is returned with error
            self.authResponse.error = error;
            onCompletHandler(self.authResponse);
        }
        else {
            [self parsePostedPoliciesResultForData:data];
            !(self.authResponse.error) ? NSLog(@"Success posting consent policies.")
                : NSLog(@"Error posting consent policies for user: %@", self.authResponse.error.description);
            onCompletHandler(self.authResponse);
        }
    };
    NSLog(@"Executing posting consents on the network.");
    [self.networkRequester performNetworkCallWithRequest:requestToPostConsent
                                    andCompletionHandler:networkingCompletionHandler];
}

-(NSURLRequest*) buildNetworkRequestForConsentSubmissionForPolicies:(NSArray*)policies
                                                       escrowTicket:(NSString*)escrowTicket {
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@%@", self.environment.PGMAuthBase,
                           PGMAuthConsentSubmitLocalPath, escrowTicket];
    
    NSLog(@"Url for submitting user consent policies is: %@", stringUrl);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:PGMAuthEscrowTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self createPostConsentJsonDataFromArray:policies]];
    
    return request;
}

- (NSData*) createPostConsentJsonDataFromArray:(NSArray*)policies
{
    NSMutableString *jsonPolicies = [NSMutableString stringWithFormat:@"{\"%@\":[", PGMAuthConsentPolicyIds];
    
    for (PGMConsentPolicy *policy in policies) {
        [jsonPolicies appendFormat:@"\"%@\",", policy.policyId];
    }
    [jsonPolicies deleteCharactersInRange:NSMakeRange([jsonPolicies length]-1, 1)];
    [jsonPolicies appendString:@"]}"];
    
    NSLog(@"The JSON string for policy Ids is %@", jsonPolicies);
    
    return [jsonPolicies dataUsingEncoding:NSUTF8StringEncoding];
}

-(void) parsePostedPoliciesResultForData:(NSData*)data {
    self.authResponse = [self.consentSerializer deserializePostedConsentPoliciesData:data
                                                                        forResponse:self.authResponse];
}

@end
