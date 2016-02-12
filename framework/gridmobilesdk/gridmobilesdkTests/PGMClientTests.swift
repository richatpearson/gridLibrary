//
//  PGMClientTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 10/31/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMClientTests: XCTestCase {
    
    var envType = PGMEnvironmentType.NoEnvironment;
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        envType = .StagingEnv
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithEnvironment() {
        var options = PGMAuthOptions()
        options.clientId = "myId10"
        options.clientSecret = "clientSecret123"
        options.redirectUrl = "http://wwww.redirecdt"
        
        var gridClient = PGMClient(environmentType: envType, andOptions: options);
        
        XCTAssertNotNil(gridClient.environment)
        XCTAssertEqual(envType, gridClient.environment.currentEnvironment);
        XCTAssertNotNil(gridClient.authenticator, "Authenticator should be set")
        XCTAssertNotNil(gridClient.options, "Options should be set")
        XCTAssertEqual(options.clientId, gridClient.options.clientId)
        XCTAssertEqual(options.clientSecret, gridClient.options.clientSecret)
        XCTAssertEqual(options.redirectUrl, gridClient.options.redirectUrl)
        
        var newAuthenticator: AnyObject? = gridClient.authenticator
        XCTAssertTrue(newAuthenticator is PGMAuthenticator)
        XCTAssertEqual(envType, gridClient.authenticator.environment.currentEnvironment)
        XCTAssertEqual(options, gridClient.authenticator.options, "Options must be set for authenticator")
        
    }
}
