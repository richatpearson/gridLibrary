//
//  PGMAuthOptionsTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthOptionsTests: XCTestCase {
    
    var clientId = "";
    var clientSecret = "";
    var rediretUrl = "";

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        clientId = "myClient1234"
        clientSecret = "secret1010"
        rediretUrl = "http://redirect.com"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        var authOptions = PGMAuthOptions(clientId: clientId, andClientSecret: clientSecret, andRedirectUrl: rediretUrl)
        
        XCTAssertEqual(clientId, authOptions.clientId)
        XCTAssertEqual(clientSecret, authOptions.clientSecret)
        XCTAssertEqual(rediretUrl, authOptions.redirectUrl)
    }
    
    func testAuthOptionsProperties() {
        var authOptions = PGMAuthOptions()
        
        XCTAssertNil(authOptions.clientId)
        XCTAssertNil(authOptions.clientSecret)
        XCTAssertNil(authOptions.redirectUrl)
        
        authOptions.clientId = clientId
        authOptions.clientSecret = clientSecret
        authOptions.redirectUrl = rediretUrl
        
        XCTAssertEqual(clientId, authOptions.clientId)
        XCTAssertEqual(clientSecret, authOptions.clientSecret)
        XCTAssertEqual(rediretUrl, authOptions.redirectUrl)
    }
}
