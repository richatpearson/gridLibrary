//
//  PGMConsentPolicy.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMConsentPolicy.h"

@implementation PGMConsentPolicy

- (id) initWithPolicyId:(NSString*)policyId
             consentUrl:(NSString*)consentUrl
            isConsented:(BOOL)isConsented
             isReviewed:(BOOL)isReviewed
{
    self = [super init];
    if (self)
    {
        self.policyId = policyId;
        self.consentPageUrl = consentUrl;
        self.isConsented = isConsented;
        self.isReviewed = isReviewed;
    }
    
    return self;
}

@end
