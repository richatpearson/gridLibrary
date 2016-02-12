//
//  PGMErrorTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMErrorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateErrorForErrorCodeAndDescription() {
        var errorUserInfo = "Something went wrong"
        var myError: AnyObject? = PGMError.createErrorForErrorCode(PGMClientErrorCode.AuthenticationError,
            andDescription: errorUserInfo)
        
        XCTAssert(myError is NSError)
        
        XCTAssertEqual(0, (myError as NSError).code)
        XCTAssertEqual(errorUserInfo, (myError as NSError).userInfo?.values.first as String)
    }

}
