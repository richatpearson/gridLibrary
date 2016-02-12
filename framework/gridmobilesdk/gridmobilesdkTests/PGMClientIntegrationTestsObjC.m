//
//  PGMClientIntegrationTestsObjC.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/11/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PGMAuthOptions.h"
#import "PGMClient.h"
#import "PGMAuthOptions.h"

@interface PGMClientIntegrationTestsObjC : XCTestCase

@end

@implementation PGMClientIntegrationTestsObjC

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) IgnoretestClientWithStagingEnv {
    
    PGMAuthOptions *clientOptions = [[PGMAuthOptions alloc] initWithClientId:@"wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5"
                                                             andClientSecret:@"secret"
                                                              andRedirectUrl:@"http://int-piapi.stg-openclass.com/pi_group12client"];
    
    PGMClient *gridClient = [[PGMClient alloc] initWithEnvironmentType:PGMStagingEnv andOptions:clientOptions];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth Expectations"];
    
    AuthenticationRequestComplete onComplete = ^(PGMAuthResponse *response) {
        if (response.error) {
            NSLog(@"Error in onComplete!");
        }
        else {
            NSLog(@"On complete success! Should have data");
        }
        
        [expectation fulfill];
    };
    
    [[gridClient authenticator] authenticateWithUserName:@"group12user" andPassword:@"P@ssword1" onComplete:onComplete];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
