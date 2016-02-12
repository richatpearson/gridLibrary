//
//  PGMConsentSerializerTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/8/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMConsentSerializerTests: XCTestCase {

    var serializer: PGMConsentSerializer? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        serializer = PGMConsentSerializer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDeserializeConsentPoliciesDataForResponse_nilData_error() {
        var response = serializer?.deserializeConsentPoliciesData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data is nil")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 24, "Error code must be of type PGMProviderReturnedNoDataError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_cannotDeserializeData_error() {
        var wrongData: String = "this is wrong data"
        var data: NSData = wrongData.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data can't be deserialized")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_dataMissingValueAttribute_error() {
        
        var dataMissingValueAttribute = "{\"createdAt\":\"2014-12-08T20:42:38.399Z\",\"id\":\"54860d3ee4b0c73458619246\"}"
        var data: NSData = dataMissingValueAttribute.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data can't be deserialized")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError when no consent policies are returned")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_dataMissingPolicyIdAttribute_error() {

        var dataMissingPolicyIdAttribute = "{\"createdAt\":\"2014-12-08T20:42:38.399Z\",\"id\":\"54860d3ee4b0c73458619246\",\"value\":\"{\\\"client_id\\\":\\\"xfTw8bxn6Cjzl3jDBX8PbOymE8jmWd4w\\\"}\"}"
        
        var data: NSData = dataMissingPolicyIdAttribute.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data can't be deserialized")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError when no consent policies are returned")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_dataMissingInPolicyId_error() {
        var dataMissingPolicyIdAttribute = "{\"createdAt\":\"2014-12-08T20:42:38.399Z\",\"id\":\"54860d3ee4b0c73458619246\",\"value\":\"{\\\"client_id\\\":\\\"xfTw8bxn6Cjzl3jDBX8PbOymE8jmWd4w\\\",\\\"policyId\\\":[{}]}\"}"
        
        var data: NSData = dataMissingPolicyIdAttribute.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data can't be deserialized")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError when no consent policies are returned")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_dataSinglePolicy_Success() {
        var dataSinglePolicy = "{\"createdAt\":\"2014-12-08T20:42:38.399Z\",\"id\":\"54860d3ee4b0c73458619246\",\"value\":\"{\\\"client_id\\\":\\\"xfTw8bxn6Cjzl3jDBX8PbOymE8jmWd4w\\\",\\\"policyId\\\":[{\\\"id\\\":\\\"5329e302e4b00568c77222b0\\\",\\\"url\\\":\\\"https://consent.com\\\",\\\"description\\\":\\\"Desc of this policy\\\"}]}\"}"
        
        var data: NSData = dataSinglePolicy.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.error)
        XCTAssertNotNil(response!.consentPolicies)
        XCTAssertEqual(1, response!.consentPolicies.count)
        XCTAssertEqual("5329e302e4b00568c77222b0", response!.consentPolicies[0].policyId)
        XCTAssertEqual("https://consent.com", response!.consentPolicies[0].consentPageUrl)
        XCTAssertFalse(response!.consentPolicies[0].isConsented!, "isConsented should be initially set to false")
        XCTAssertFalse(response!.consentPolicies[0].isReviewed!, "isReviewed should be initially set to false")
    }
    
    func testDeserializeConsentPoliciesDataForResponse_dataTwoPolicies_Success() {
        var dataSinglePolicy = "{\"createdAt\":\"2014-12-08T20:42:38.399Z\",\"id\":\"54860d3ee4b0c73458619246\",\"value\":\"{\\\"client_id\\\":\\\"xfTw8bxn6Cjzl3jDBX8PbOymE8jmWd4w\\\",\\\"policyId\\\":[{\\\"id\\\":\\\"5329e302e4b00568c77222b0\\\",\\\"url\\\":\\\"https://consent.com\\\",\\\"description\\\":\\\"Desc of this policy\\\"},{\\\"id\\\":\\\"52b1bd48e4b0263ac9b8ed1d\\\",\\\"url\\\":\\\"https://consent_2.com\\\",\\\"description\\\":\\\"Desc of my 2nd policy\\\"}]}\"}"
        
        var data: NSData = dataSinglePolicy.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.error)
        XCTAssertNotNil(response!.consentPolicies)
        XCTAssertEqual(2, response!.consentPolicies.count)
        
        XCTAssertEqual("5329e302e4b00568c77222b0", response!.consentPolicies[0].policyId)
        XCTAssertEqual("https://consent.com", response!.consentPolicies[0].consentPageUrl)
        XCTAssertFalse(response!.consentPolicies[0].isConsented!, "isConsented should be initially set to false")
        XCTAssertFalse(response!.consentPolicies[0].isReviewed!, "isReviewed should be initially set to false")
        
        XCTAssertEqual("52b1bd48e4b0263ac9b8ed1d", response!.consentPolicies[1].policyId)
        XCTAssertEqual("https://consent_2.com", response!.consentPolicies[1].consentPageUrl)
        XCTAssertFalse(response!.consentPolicies[1].isConsented!, "isConsented should be initially set to false")
        XCTAssertFalse(response!.consentPolicies[1].isReviewed!, "isReviewed should be initially set to false")
    }
    
    // MARK: post consent unit tests
    func testDeserializePostedConsentPoliciesDataForResponse_nilData_error() {
        var response = serializer?.deserializePostedConsentPoliciesData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data is nil")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 24, "Error code must be of type PGMProviderReturnedNoDataError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializePostedConsentPoliciesDataForResponse_cannotDeserializeData_error() {
        var wrongData: String = "this is wrong data"
        var data: NSData = wrongData.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializePostedConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.consentPolicies, "consentPolicies property should be nil when data can't be deserialized")
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializePostedConsentPoliciesDataForResponse_missingStatusKey_error() {
        var jsonMissingStatus = "{\"key\":\"value\"}"
        
        var data: NSData = jsonMissingStatus.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializePostedConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    //PGMAuthConsentSubmitStatus] isEqual:PGMAuthConsentSubmitSuccess
    
    func testDeserializePostedConsentPoliciesDataForResponse_FailureStatus_error() {
        var jsonFailureStatus = "{\"\(PGMAuthConsentSubmitStatus)\":\"failure\",\"data\":null}"
        
        var data: NSData = jsonFailureStatus.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializePostedConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response!.error)
        XCTAssertEqual(response!.error.code, 8, "Error code must be of type AuthConsentFlowError")
        XCTAssertTrue((response!.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
    }
    
    func testDeserializePostedConsentPoliciesDataForResponse_SuccessStatus_success() {
        var jsonFailureStatus = "{\"\(PGMAuthConsentSubmitStatus)\":\"\(PGMAuthConsentSubmitSuccess)\",\"data\":null}"
        
        var data: NSData = jsonFailureStatus.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializePostedConsentPoliciesData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response!.error)
    }
}
