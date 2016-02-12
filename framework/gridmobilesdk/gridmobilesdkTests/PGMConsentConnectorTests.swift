//
//  PGMConsentConnectorTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/9/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMConsentConnectorTests: XCTestCase {
    
    var env: PGMEnvironment!
    var escrowTicket: String!
    var consentPolicies: Array<PGMConsentPolicy>!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        env = PGMEnvironment(environmentFromType: .StagingEnv)
        escrowTicket = "escrow12345"
        
        var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: false, isReviewed: false)
        var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: false, isReviewed: false)
        var consentPolicies = Array<PGMConsentPolicy>()
        consentPolicies.append(consentPolicy1)
        consentPolicies.append(consentPolicy2)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithEnvironment() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        
        var consentConnector = PGMConsentConnector(environment: env)
        
        XCTAssertNotNil(consentConnector.consentSerializer, "PGMConsentSerializer is supposed to be set during init")
        XCTAssertNotNil(consentConnector.networkRequester, "PGMCoreNetworkRequester is supposed to be set during init")
        XCTAssertNotNil(consentConnector.environment, "PGMEnvironment ire")
    }
    
    func testRunPoliciesRequestWithEscrowTicketForResponse_errorInCoreRequester_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error in completionHandler network call"))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
    
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runPoliciesRequestWithEscrowTicket(escrowTicket, forResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("Error in completionHandler network call", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with network error")
    }
    
    func testRunPoliciesRequestWithEscrowTicketForResponse_errorInCoreRequesterWithData_error() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Mock error from core network requester."))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializeConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthConsentFlowError, andDescription: "Mock error from serializer.")
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runPoliciesRequestWithEscrowTicket(escrowTicket, forResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(8, responseFromCompleteBlock!.error.code, "Error code should be .AuthConsentFlowError")
        XCTAssertEqual("Mock error from serializer.", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with serializer error")
    }
    
    func testRunPoliciesRequestWithEscrowTicketForResponse_errorInSerializer_error() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil)
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializeConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthConsentFlowError, andDescription: "Mock error from serializer only.")
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runPoliciesRequestWithEscrowTicket(escrowTicket, forResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(8, responseFromCompleteBlock!.error.code, "Error code should be .AuthConsentFlowError")
        XCTAssertEqual("Mock error from serializer only.", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with serializer error")
    }
    
    func testRunPoliciesRequestWithEscrowTicketForResponse_success() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil)
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializeConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: false, isReviewed: false)
                var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: false, isReviewed: false)
                var mockConsentPolicies = Array<PGMConsentPolicy>()
                mockConsentPolicies.append(consentPolicy1)
                mockConsentPolicies.append(consentPolicy2)
                
                response.consentPolicies = mockConsentPolicies
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            (authResponse.error == nil) ? println("No error - success!")
                : println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runPoliciesRequestWithEscrowTicket(escrowTicket, forResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock?.consentPolicies)
        XCTAssertEqual(2, responseFromCompleteBlock!.consentPolicies.count, "We set 2 policies in serializer mock")
        
        XCTAssertEqual("12345", responseFromCompleteBlock!.consentPolicies[0].policyId)
        XCTAssertEqual("http://consent_1.com", responseFromCompleteBlock!.consentPolicies[0].consentPageUrl)
        XCTAssertFalse(responseFromCompleteBlock!.consentPolicies[0].isConsented!, "isConsented in consent policy is init to false")
        XCTAssertFalse(responseFromCompleteBlock!.consentPolicies[0].isReviewed!, "isReviewed in consent policy is init to false")
        
        XCTAssertEqual("67890", responseFromCompleteBlock!.consentPolicies[1].policyId)
        XCTAssertEqual("http://consent_2.com", responseFromCompleteBlock!.consentPolicies[1].consentPageUrl)
        XCTAssertFalse(responseFromCompleteBlock!.consentPolicies[1].isConsented!, "isConsented in consent policy is init to false")
        XCTAssertFalse(responseFromCompleteBlock!.consentPolicies[1].isReviewed!, "isReviewed in consent policy is init to false")
    }
    
    func testRrunConsentSubmissionForPolicyIdsEscrowTicketResponse_errorInCoreRequester_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error in completionHandler network call"))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runConsentSubmissionForPolicyIds(consentPolicies, escrowTicket: escrowTicket,
                                                            response: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("Error in completionHandler network call", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with network error")
    }
    
    func testRrunConsentSubmissionForPolicyIdsEscrowTicketResponse_errorInCoreRequesterWithData_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Mock error from core network requester."))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializePostedConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthConsentFlowError, andDescription: "Mock error from serializer.")
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runConsentSubmissionForPolicyIds(consentPolicies, escrowTicket: escrowTicket,
            response: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(8, responseFromCompleteBlock!.error.code, "Error code should be .AuthConsentFlowError")
        XCTAssertEqual("Mock error from serializer.", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with serializer error")
    }
    
    func testRrunConsentSubmissionForPolicyIdsEscrowTicketResponse_errorInSerializer_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil)
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializePostedConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthConsentFlowError, andDescription: "Mock error from serializer.")
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runConsentSubmissionForPolicyIds(consentPolicies, escrowTicket: escrowTicket,
            response: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(8, responseFromCompleteBlock!.error.code, "Error code should be .AuthConsentFlowError")
        XCTAssertEqual("Mock error from serializer.", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with serializer error")
    }
    
    func testRrunConsentSubmissionForPolicyIdsEscrowTicketResponse_success() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil)
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        class MockConsentSerializer: PGMConsentSerializer {
            
            private override func deserializePostedConsentPoliciesData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                return response
            }
        }
        
        let mockConsentSerializer = MockConsentSerializer()
        
        var consentConnector = PGMConsentConnector(environment: env)
        consentConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        consentConnector.consentSerializer = mockConsentSerializer
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            (authResponse.error == nil) ? println("No error - success!")
                : println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        consentConnector.runConsentSubmissionForPolicyIds(consentPolicies, escrowTicket: escrowTicket,
            response: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNil(responseFromCompleteBlock!.consentPolicies, "No consent policies with serializer error")
    }
}
