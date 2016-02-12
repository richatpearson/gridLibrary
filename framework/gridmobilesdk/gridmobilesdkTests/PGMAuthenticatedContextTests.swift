//
//  PGMAuthenticatedContextTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import GRIDMobileSDK

class PGMAuthenticatedContextTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAuthenticatedContextInit() {
        var accessToken = "token1234"
        var usrRefreshToken = "refresh555"
        var tokenExpiresIn:Int = 2000
        
        var authContext = PGMAuthenticatedContext(accessToken: accessToken, refreshToken: usrRefreshToken, andExpirationInterval: 2000)
        
        XCTAssertEqual(accessToken, authContext.accessToken)
        XCTAssertEqual(usrRefreshToken, authContext.refreshToken)
        XCTAssertEqual(tokenExpiresIn, authContext.tokenExpiresIn)
        XCTAssertNotNil(authContext.creationDateInterval)
        XCTAssertNil(authContext.userIdentityId)
        XCTAssertNil(authContext.username)
    }
    
    func testAuthenticatedContextProperties() {
        var accessToken = "token1234"
        var usrIdentityId = "12345Id"
        var usrRefreshToken = "refresh555"
        var tokenExpiresIn:Int = 2000
        var username = "myUsername"
        var password = "myPassword"
        var authContext = PGMAuthenticatedContext(accessToken: accessToken, refreshToken: usrRefreshToken, andExpirationInterval: 2000)
        
        authContext.userIdentityId = usrIdentityId
        authContext.username = username
        
        XCTAssertEqual(accessToken, authContext.accessToken)
        XCTAssertEqual(usrIdentityId, authContext.userIdentityId)
        XCTAssertEqual(usrRefreshToken, authContext.refreshToken)
        XCTAssertEqual(tokenExpiresIn, authContext.tokenExpiresIn)
        XCTAssertEqual(username, authContext.username)
        XCTAssertNotNil(authContext.creationDateInterval)
        
    }
    
    func testIsTokenCurrent_current_true() {
        var accessToken = "token1234"
        var usrRefreshToken = "refresh555"
        
        var authContext = PGMAuthenticatedContext(accessToken: accessToken, refreshToken: usrRefreshToken, andExpirationInterval: 5)
        
        XCTAssertTrue(authContext.isTokenCurrent(), "Access token should be valid for 5 seconds")
    }
    
    func testIsTokenCurrent_0timeInterval_false() {
        var accessToken = "token1234"
        var usrRefreshToken = "refresh555"
        
        var authContext = PGMAuthenticatedContext(accessToken: accessToken, refreshToken: usrRefreshToken, andExpirationInterval: 0)
        
        XCTAssertFalse(authContext.isTokenCurrent(), "Access token should be invalid when expiration interval is set to 0 seconds")
    }
    
    func testIsTokenCurrent_non0TimeInterval_expired_false() {
        var accessToken = "token1234"
        var usrRefreshToken = "refresh555"
        
        var authContext = PGMAuthenticatedContext(accessToken: accessToken, refreshToken: usrRefreshToken, andExpirationInterval: 1)
        sleep(1)
        
        XCTAssertFalse(authContext.isTokenCurrent(), "Access token should be invalid when slightly more time elapses than specified in expiration interval")
    }
}
