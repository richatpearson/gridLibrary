//
//  PGMConsentSerializer.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMConsentSerializer.h"
#import "PGMConsentPolicy.h"
#import "PGMConstants.h"

@interface PGMConsentSerializer()

@property (nonatomic, strong) NSDictionary *authDataDict;
@property (nonatomic, strong) NSError *authError;

@end

@implementation PGMConsentSerializer

- (PGMAuthResponse*) deserializeConsentPoliciesData:(NSData*)data
                                        forResponse:(PGMAuthResponse*)response {
    if (!data)
    {
        response.error =
        [PGMError createErrorForErrorCode:PGMProviderReturnedNoDataError
                           andDescription:@"Escrow Policies API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    NSLog(@"JSON from Escrow User consent policies call is: %@:::error: %@", self.authDataDict, self.authError);
    
    if (self.authError) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription:@"Cannot deserialize escrow consent policies data"];
        return response;
    }
    
    NSMutableArray *consentPolicyArray = [[NSMutableArray alloc] init];
    
    NSDictionary *consentPolicies = [self parseConsentPoliciesFromDict:self.authDataDict];
    
    if (!consentPolicies || consentPolicies.count < 1) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription:@"No consent policies for user"];
        return response;
    }
    
    for (NSDictionary *item in consentPolicies) {
        NSString *policyId = [item objectForKey:@"id"];
        NSString *consentUrl = [item objectForKey:@"url"];
        if (policyId && ![policyId isEqualToString:@""] && consentUrl && ![consentUrl isEqualToString:@""]) {
            [consentPolicyArray addObject:[self createConsentPolicyWithPolicyId:policyId consentUrl:consentUrl]];
        }
    }
    
    if (consentPolicyArray.count < 1) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription:@"No consent policies for user"];
        return response;
    }
    
    response.consentPolicies = consentPolicyArray;
    
    return response;
}

-(void) deserializeData:(NSData*)data {
    NSError *jsonError = nil;
    self.authDataDict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data
                                                                       options:kNilOptions
                                                                         error:&jsonError];
    self.authError = jsonError;
}


- (NSDictionary*) parseConsentPoliciesFromDict:(NSDictionary*)jsonDict
{
    NSString *consentValue = [jsonDict objectForKey:@"value"];
    if (!consentValue) {
        return nil;
    }
    
    NSError *jsonError = nil;
    NSDictionary *consentValueDict =
    [NSJSONSerialization JSONObjectWithData: [consentValue dataUsingEncoding:NSUTF8StringEncoding]
                                    options: kNilOptions
                                      error: &jsonError];
    if (jsonError || !consentValueDict)
    {
        return nil;
    }
    
    NSDictionary *consentPolicies = [consentValueDict objectForKey:@"policyId"];
    
    return consentPolicies;
}

- (PGMConsentPolicy*) createConsentPolicyWithPolicyId:(NSString*)policyId
                                           consentUrl:(NSString*)url {
    PGMConsentPolicy *consent = [[PGMConsentPolicy alloc] initWithPolicyId:policyId
                                                                consentUrl:url
                                                               isConsented:NO
                                                                isReviewed:NO];
    
    return consent;
}

- (PGMAuthResponse*) deserializePostedConsentPoliciesData:data
                                              forResponse:(PGMAuthResponse*)response {
    if (!data)
    {
        response.error =
        [PGMError createErrorForErrorCode:PGMProviderReturnedNoDataError
                           andDescription:@"Post user consent policies API returned no data"];
        return response;
    }
    
    [self deserializeData:data];
    
    NSLog(@"JSON from posting User's consent policies call is: %@:::error: %@", self.authDataDict, self.authError);
    
    if (self.authError) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription:@"Cannot deserialize post user consent policies data"];
        return response;
    }
    
    if (![[self.authDataDict objectForKey:PGMAuthConsentSubmitStatus] isEqual:PGMAuthConsentSubmitSuccess]) {
        response.error = [PGMError createErrorForErrorCode:PGMAuthConsentFlowError andDescription:@"Pi returned failure posting user consents"];
        return response;
    }
    
    return response;
}

@end

