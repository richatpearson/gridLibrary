//
//  PGMAuthResponseTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthResponseTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateAuthResponse_nilPoperties() {
        var authResponse = PGMAuthResponse()
        
        XCTAssertNotNil(authResponse)
        XCTAssertNil(authResponse.error)
        XCTAssertNil(authResponse.authContext)
        XCTAssertNil(authResponse.escrowTicket)
        XCTAssertNil(authResponse.consentPolicies)
    }
    
    func testCreateAuthResponseWithProperties() {
        var authResponse = PGMAuthResponse()
        authResponse.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "ErrorTestMsg")
        authResponse.authContext = PGMAuthenticatedContext(accessToken: "token12345", refreshToken: "refresh12345", andExpirationInterval: 1000)
        authResponse.escrowTicket = "escrow123"
        var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent.com", isConsented: false, isReviewed: false)
        var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: true, isReviewed: true)
        authResponse.consentPolicies = Array<PGMConsentPolicy>()
        authResponse.consentPolicies.append(consentPolicy1)
        authResponse.consentPolicies.append(consentPolicy2)
        
        XCTAssertNotNil(authResponse)
        XCTAssertEqual(0, authResponse.error.code)
        XCTAssertNotNil(authResponse.authContext)
        XCTAssertEqual("token12345", authResponse.authContext.accessToken)
        XCTAssertEqual("refresh12345", authResponse.authContext.refreshToken)
        XCTAssertEqual(1000, authResponse.authContext.tokenExpiresIn)
        XCTAssertEqual("escrow123", authResponse.escrowTicket)
        XCTAssertEqual(2, authResponse.consentPolicies.count)
        XCTAssertEqual(consentPolicy1.policyId, authResponse.consentPolicies[0].policyId)
        XCTAssertEqual(consentPolicy1.consentPageUrl, authResponse.consentPolicies[0].consentPageUrl)
        XCTAssertEqual(consentPolicy1.isConsented, authResponse.consentPolicies[0].isConsented)
        XCTAssertEqual(consentPolicy1.isReviewed, authResponse.consentPolicies[0].isReviewed)
        XCTAssertEqual(consentPolicy2.policyId, authResponse.consentPolicies[1].policyId)
        XCTAssertEqual(consentPolicy2.consentPageUrl, authResponse.consentPolicies[1].consentPageUrl)
        XCTAssertEqual(consentPolicy2.isConsented, authResponse.consentPolicies[1].isConsented)
        XCTAssertEqual(consentPolicy2.isReviewed, authResponse.consentPolicies[1].isReviewed)
    }
}
