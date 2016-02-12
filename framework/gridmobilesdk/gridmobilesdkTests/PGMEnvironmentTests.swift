//
//  PGMEnvironmentTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMEnvironmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEnvironmentProperties() {
        var authBaseUrl = "http://authbase.com"
        var authSuccessUrl = "http://successUrl.com"
        var escrowBaseUrl = "http://escrowbase.com"
        var env = PGMEnvironment()
        env.currentEnvironment = .StagingEnv
        env.PGMAuthBase = authBaseUrl
        env.PGMAuthLoginSuccessUrl = authSuccessUrl;
        env.PGMAuthEscrowBase = escrowBaseUrl
        
        XCTAssertTrue(env.currentEnvironment == .StagingEnv);
        XCTAssertFalse(env.currentEnvironment == .ProductionEnv);
        XCTAssertEqual(authBaseUrl, env.PGMAuthBase)
        XCTAssertEqual(authSuccessUrl, env.PGMAuthLoginSuccessUrl);
        XCTAssertEqual(escrowBaseUrl, env.PGMAuthEscrowBase)
    }
    
    func testInitEnvironmentFromType() {
        var env = PGMEnvironment(environmentFromType: .ProductionEnv)
        
        XCTAssertTrue(env.currentEnvironment == .ProductionEnv)
        XCTAssertEqual(PGMAuthBase_Prod, env.PGMAuthBase)
        XCTAssertEqual(PGMAuthLoginSuccessUrl_Prod, env.PGMAuthLoginSuccessUrl)
        XCTAssertEqual(PGMAuthEscrowBase_Prod, env.PGMAuthEscrowBase)
    }
}
