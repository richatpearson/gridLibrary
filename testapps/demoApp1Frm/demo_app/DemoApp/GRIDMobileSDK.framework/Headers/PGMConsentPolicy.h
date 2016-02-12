//
//  PGMConsentPolicy.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMConsentPolicy : NSObject

@property (nonatomic, strong) NSString *policyId;
@property (nonatomic, strong) NSString *consentPageUrl;
@property (nonatomic, assign) BOOL isConsented;
@property (nonatomic, assign) BOOL isReviewed;

- (id) initWithPolicyId:(NSString*)policyId
             consentUrl:(NSString*)consentUrl
            isConsented:(BOOL)isConsented
             isReviewed:(BOOL)isReviewed;

@end
