//
//  PGMAuthMockDataProviderTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/7/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthMockDataProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProvideTokenWithUsernamePassword_invlidUserNamePassword_error () {
        var authMockDataProvider = PGMAuthMockDataProvider()
        
        //inavlid uesername scenario:
        var invalidUsernameErrorData = authMockDataProvider.provideTokenWithUsername("incorrectUsername", password: PGMAuthMockPassword)
        
        var jsonError: NSError?
        let dataDict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(invalidUsernameErrorData,
            options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
        
        XCTAssertNil(dataDict, "Should be nil when invalid credentials")
        if (jsonError != nil) {
                println("We got error \(jsonError!.code)")
        }
        
        XCTAssertNotNil(jsonError!.code)
        XCTAssertEqual(3840, jsonError!.code, "Should have received error code 3840 - 'unable to parse as JSON' error")
        
        //inavlid password scenario:
        var invalidPasswordErrorData = authMockDataProvider.provideTokenWithUsername(PGMAuthMockUsername, password: "invlaidPasswrd")
        
        var jsonPasswrdError: NSError?
        let badPasswrdDataDict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(invalidPasswordErrorData,
            options: NSJSONReadingOptions.MutableContainers, error: &jsonPasswrdError) as? NSDictionary
        
        XCTAssertNil(badPasswrdDataDict, "Should be nil when invalid credentials")
        XCTAssertNotNil(jsonPasswrdError!.code)
        XCTAssertEqual(3840, jsonPasswrdError!.code, "Should have received error code 3840 - 'unable to parse as JSON' error")
    }
    
    func testProvideTokenWithUsernamePassword_validNamePassword_success () {
        
        var authMockDataProvider = PGMAuthMockDataProvider()
        var data = authMockDataProvider.provideTokenWithUsername(PGMAuthMockUsername, password: PGMAuthMockPassword)
        
        var jsonError: NSError?
        let dataDict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
        
        XCTAssertNotNil(dataDict, "Should not be nil when mock credentials are valid")
        XCTAssertNil(jsonError)
        
        XCTAssertEqual(PGMAuthMockAccessToken, dataDict.objectForKey("access_token") as NSString)
        XCTAssertEqual(PGMAuthMockRefreshToken, dataDict.objectForKey("refresh_token") as NSString)
        XCTAssertEqual(String(PGMAuthMockTokenExpiresIn), dataDict.objectForKey("expires_in") as String)
    }
}
