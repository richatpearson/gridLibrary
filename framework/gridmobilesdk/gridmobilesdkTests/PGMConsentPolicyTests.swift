//
//  PGMConsentPolicyTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMConsentPolicyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitializeConsentPolicy () {
        var policyId: String = "12345"
        var consentUrl: String = "http://consent.com"
        var isConsented: Bool = true
        var isReviewed: Bool = true
        
        var consentPolicy = PGMConsentPolicy(policyId: policyId, consentUrl: consentUrl, isConsented: isConsented,
            isReviewed: isReviewed)
        
        XCTAssertEqual(policyId, consentPolicy.policyId)
        XCTAssertEqual(consentUrl, consentPolicy.consentPageUrl)
        XCTAssertEqual(isConsented, consentPolicy.isConsented)
        XCTAssertEqual(isReviewed, consentPolicy.isReviewed)
    }
    
    func testConsentPolicyProperties() {
        
        var consentPolicy = PGMConsentPolicy()
        
        XCTAssertNil(consentPolicy.policyId)
        XCTAssertNil(consentPolicy.consentPageUrl)
        XCTAssertTrue(!consentPolicy.isConsented)
        XCTAssertTrue(!consentPolicy.isReviewed)
        
        var policyId: String = "12345"
        var consentUrl: String = "http://consent.com"
        var isConsented: Bool = true
        var isReviewed: Bool = true
        
        consentPolicy.policyId = policyId
        consentPolicy.consentPageUrl = consentUrl
        consentPolicy.isConsented = isConsented
        consentPolicy.isReviewed = isReviewed
        
        XCTAssertEqual(policyId, consentPolicy.policyId)
        XCTAssertEqual(consentUrl, consentPolicy.consentPageUrl)
        XCTAssertEqual(isConsented, consentPolicy.isConsented)
        XCTAssertEqual(isReviewed, consentPolicy.isReviewed)
    }
}
