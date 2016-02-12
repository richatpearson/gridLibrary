//
//  PGMForgotUsernamePasswordTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 2/20/15.
//  Copyright (c) 2015 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMForgotUsernamePasswordTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func IgnoretestForgotUsernameForEmailOnComplete() {
        var clientOptions = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "secret", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        var gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
        
        let expectation = expectationWithDescription("Auth forgot username expectation")
        
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block - error!")
                println("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo?.values.first as String)")
            }else {
                println("Executing completion block - success!!")
            }
            
            XCTAssertNil(authResponse.authContext, "No auth context")
            XCTAssertNil(authResponse.error)
            
            expectation.fulfill()
        }
        
        gridClient.authenticator.forgotUsernameForEmail("richard.rosiak@pearson.com", onComplete: onComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func IgnoretestForgotPasswordForUsernameOnComplete() {
        var clientOptions = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "secret", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        var gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
        
        let expectation = expectationWithDescription("Auth forgot password expectation")
        
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block - error!")
                println("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo?.values.first as String)")
            }else {
                println("Executing completion block - success!!")
            }
            
            XCTAssertNil(authResponse.authContext, "No auth context")
            XCTAssertNil(authResponse.error)
            
            expectation.fulfill()
        }
        
        gridClient.authenticator.forgotPasswordForUsername("mrstudent1", onComplete: onComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
