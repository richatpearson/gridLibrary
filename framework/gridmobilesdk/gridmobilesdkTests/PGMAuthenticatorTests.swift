//
//  PGMAuthenticatorTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthenticatorTests: XCTestCase {
    
    var stagingEnv: AnyObject? = nil
    var authOptions: AnyObject? = nil
    var username: String? = nil
    var password: String? = nil
    var token: String? = nil
    var userId: String? = nil
    var authenticator: PGMAuthenticator!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        stagingEnv = PGMEnvironment(environmentFromType: .StagingEnv)
        authOptions = PGMAuthOptions(clientId: "myClientId", andClientSecret: "shhh - it's a secret",
            andRedirectUrl: "http://redirect.com")
        username = "bobby"
        password = "12345"
        token = "token123"
        userId = "12345Id"
        
        authenticator = PGMAuthenticator(environment: stagingEnv as! PGMEnvironment,
            andOptions: authOptions as! PGMAuthOptions)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithEnvironmentAndOptionsTest_nilArguments() {
        let authenticator = PGMAuthenticator(environment: nil, andOptions: nil);
        
        XCTAssertNotNil(authenticator, "Initialized authenticator must not be nil")
        XCTAssertNil(authenticator.environment)
        XCTAssertNil(authenticator.options)
        XCTAssertNotNil(authenticator.authConnector, "Auth connector should be set")
        XCTAssertNotNil(authenticator.authKeychainStorageManager, "Keychain storage manager should be set")
    }
    
    func testInitWithEnvironmentAndOptionsTest_notNilArguments() {
        
        XCTAssertNotNil(authenticator, "Initialized authenticator must not be nil")
        XCTAssertNotNil(authenticator.environment)
        XCTAssertNotNil(authenticator.options)
        XCTAssertNotNil(authenticator.authConnector, "Auth connector should be set")
        XCTAssertNotNil(authenticator.authKeychainStorageManager, "Keychain storage manager should be set")
    }
    
    func testAuthenticateWithUsernameAndPassword_nilParams_error() {
        
        var responseFromBlock: PGMAuthResponse? = nil
        
        let onComplete: AuthenticationRequestComplete =  {(PGMAuthResponse) -> () in
            
            if (PGMAuthResponse.error != nil) {
                print("Error in completion block")
            }else {
                print("Success in completion block")
            }
            responseFromBlock = PGMAuthResponse
        }
        NSLog("Will run asserts...")
        authenticator.authenticateWithUserName(nil, andPassword: nil, onComplete: onComplete)
        XCTAssertNotNil(responseFromBlock!.error, "Missing username and password - need to produce response with an error")
        
        authenticator.authenticateWithUserName(nil, andPassword: "myPassword", onComplete: onComplete)
        XCTAssertNotNil(responseFromBlock!.error, "Missing username - need to produce response with an error")
        
        authenticator.authenticateWithUserName("myUsername", andPassword: nil, onComplete: onComplete)
        XCTAssertNotNil(responseFromBlock!.error, "Missing password - need to produce response with an error")
    }
    
    func testAuthenticateWithUserNameAndPassword_success() {
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    print("In mock function run login")
                    response.authContext = PGMAuthenticatedContext(accessToken: "token123",
                        refreshToken: "refreshToken456", andExpirationInterval: 1000)
                    completionHandler(response)
            }
            
            private override func runUserIdRequestWithResponse(response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                print("In mock function run userId")
                response.authContext.userIdentityId = "ffMyuser555"
                completionHandler(response)
            }
        }
        
        //-(BOOL) storeKeychainAuthenticatedContext:(PGMAuthenticatedContext*)context error:(NSError**)error
        
        class MockKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return true
            }
        }
        
        let mockConnector = MockAuthConnector()
        let mockKeychainStorageManager = MockKeychainStorageManager()
        
        authenticator.setConnector(mockConnector)
        authenticator.setKeychainStorageManager(mockKeychainStorageManager)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        let clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            print("Running onComplete...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNil(clientResponse!.error, "Shouldn't get error in success run")
        XCTAssertEqual("token123", clientResponse!.authContext.accessToken)
        XCTAssertEqual("refreshToken456", clientResponse!.authContext.refreshToken)
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn)
        XCTAssertEqual("ffMyuser555", clientResponse!.authContext.userIdentityId)
    }
    
    func testAuthenticateWithUserNameAndPassword_loginReturnsError_error() {
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    print("In mock function run login")
                    response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockLoginError")
                    completionHandler(response)
            }
        }
        
        let mockConnector = MockAuthConnector()
        
        authenticator.setConnector(mockConnector)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        let clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            print("Running onComplete...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNil(clientResponse!.authContext)
        XCTAssertNotNil(clientResponse!.error, "Error must be returned")
        XCTAssertEqual(0, clientResponse!.error.code)
        XCTAssertEqual("mockLoginError", clientResponse!.error.userInfo.values.first as? String, "Wrong error msg")
    }
    
    func testAuthenticateWithUserNameAndPassword_userIdReturnsError_error() {
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    print("In mock function run login")
                    response.authContext = PGMAuthenticatedContext(accessToken: "token123", refreshToken: nil, andExpirationInterval: 0)
                    completionHandler(response)
            }
            
            private override func runUserIdRequestWithResponse(response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                print("In mock function run userId")
                response.error = PGMError.createErrorForErrorCode(.AuthUserIdError, andDescription: "MockUserIdError")
                completionHandler(response)
            }
        }
        
        let mockConnector = MockAuthConnector()
        
        authenticator.setConnector(mockConnector)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        let clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            print("Running onComplete...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNotNil(clientResponse!.error, "Error must be returned")
        XCTAssertEqual(5, clientResponse!.error.code)
        XCTAssertEqual("MockUserIdError", clientResponse!.error.userInfo.values.first as? String, "Wrong error msg")
    }
    
    func testAuthenticateWithUserNameAndPassword_NilContextForKaychain_Error() {
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    print("In mock function run login")
                    response.authContext = PGMAuthenticatedContext(accessToken: "token123",
                        refreshToken: "refreshToken456", andExpirationInterval: 1000)
                    completionHandler(response)
            }
            
            private override func runUserIdRequestWithResponse(response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                print("In mock function run userId")
                completionHandler(response)
            }
        }
        
        class MockKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                println("In mock function store keychain.")
                var myError: NSError? = PGMError.createErrorForErrorCode(.AuthMissingContextError, andDescription: "Missing authContext.")
                if (error != nil) {
                    println("In mock store keychain method - will set error.memory")
                    error.memory = myError
                }
                return false
            }
        }
        
        let mockConnector = MockAuthConnector()
        let mockKeychainStorageManager = MockKeychainStorageManager()
        
        authenticator.setConnector(mockConnector)
        authenticator.setKeychainStorageManager(mockKeychainStorageManager)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNotNil(clientResponse!.error, "Should get error - from key chain")
        XCTAssertEqual(6, clientResponse!.error.code, "Error should be of type AuthMissingContextError")
        XCTAssertEqual("token123", clientResponse!.authContext.accessToken, "Auth context data should be retained in case of keychain error")
        XCTAssertEqual("refreshToken456", clientResponse!.authContext.refreshToken, "Auth context data should be retained in case of keychain error")
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn, "Auth context data should be retained in case of keychain error")
    }
    
    func testAuthenticateWithUserNameAndPassword_CantStoreDataInKaychain_Error() {
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    println("In mock function run login")
                    response.authContext = PGMAuthenticatedContext(accessToken: "token123",
                        refreshToken: "refreshToken456", andExpirationInterval: 1000)
                    completionHandler(response)
            }
            
            private override func runUserIdRequestWithResponse(response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                println("In mock function run userId")
                response.authContext.userIdentityId = "ffMyuser555"
                completionHandler(response)
            }
        }
        
        class MockKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                if (error != nil) {
                    println("In mock store keychain method - yo, error is not nil!!")
                }
                return false
            }
        }
        
        let mockConnector = MockAuthConnector()
        let mockKeychainStorageManager = MockKeychainStorageManager()
        
        authenticator.setConnector(mockConnector)
        authenticator.setKeychainStorageManager(mockKeychainStorageManager)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNotNil(clientResponse!.error, "Should get error - from key chain")
        XCTAssertEqual(7, clientResponse!.error.code, "Error should be of type UnableToStoreContextInKeychainError")
        XCTAssertEqual("token123", clientResponse!.authContext.accessToken, "Auth context data should be retained in case of keychain error")
        XCTAssertEqual("refreshToken456", clientResponse!.authContext.refreshToken, "Auth context data should be retained in case of keychain error")
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn, "Auth context data should be retained in case of keychain error")
        XCTAssertEqual("ffMyuser555", clientResponse!.authContext.userIdentityId, "Auth context data should be retained in case of keychain error")
    }
    
    func testAuthenticateWithUserNameAndPassword_userNeedsConsent_error() {
        
        class MockAuthConnector: PGMAuthConnector {
            private override func runAuthenticationRequestWithUsername(username: String!, password: String!, andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                println("In mock function run login - no consent")
                response.error = PGMError.createErrorForErrorCode(.AuthNoConsentError, andDescription: "No consent for user")
                response.escrowTicket = "escrow12345"
                completionHandler(response)
            }
        }
        
        class MockConsentConnector: PGMConsentConnector {
            private override func runPoliciesRequestWithEscrowTicket(escrowTicket: String!, forResponse response: PGMAuthResponse!, onComplete onCompletHandler: AuthenticationRequestComplete!) {
                var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: false, isReviewed: false)
                var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: false, isReviewed: false)
                response.consentPolicies = Array<PGMConsentPolicy>()
                response.consentPolicies.append(consentPolicy1)
                response.consentPolicies.append(consentPolicy2)
                onCompletHandler(response)
            }
        }
        
        let mockAuthConnector = MockAuthConnector()
        let mockConsentConnector = MockConsentConnector()
        
        authenticator.setConnector(mockAuthConnector)
        authenticator.consentConnector = mockConsentConnector
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client onComplete - no consent...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.authenticateWithUserName(username, andPassword: password, onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNil(clientResponse!.authContext, "no authContext for lack of user consent scenario")
        XCTAssertNotNil(clientResponse!.error, "Error must be returned")
        XCTAssertEqual(2, clientResponse!.error.code, "error type should have been .AuthNoConsentError")
        XCTAssertEqual("No consent for user", clientResponse!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertEqual("escrow12345", clientResponse!.escrowTicket, "escrow ticket was set to escrow12345")
        XCTAssertEqual(2, clientResponse!.consentPolicies.count, "Should have two consent policies")
        
        XCTAssertEqual("12345", clientResponse!.consentPolicies[0].policyId)
        XCTAssertEqual("http://consent_1.com", clientResponse!.consentPolicies[0].consentPageUrl)
        XCTAssertFalse(clientResponse!.consentPolicies[0].isConsented!)
        XCTAssertFalse(clientResponse!.consentPolicies[0].isReviewed!)
        
        XCTAssertEqual("67890", clientResponse!.consentPolicies[1].policyId)
        XCTAssertEqual("http://consent_2.com", clientResponse!.consentPolicies[1].consentPageUrl)
        XCTAssertFalse(clientResponse!.consentPolicies[1].isConsented!)
        XCTAssertFalse(clientResponse!.consentPolicies[1].isReviewed!)
    }
    
    func testSubmitUserConsentPoliciesWithUsernamePasswordEscrow_noEscrowTicket_error() {
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client onComplete - post consents - no escrow ticket...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.submitUserConsentPolicies(Array<PGMConsentPolicy>(), withUsername: username, password: password,
            escrowTicket: nil, onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(8, clientResponse!.error.code, "Error needs to be of type .AuthConsentFlowError")
        XCTAssertEqual("No escrow ticket included in request", clientResponse!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(clientResponse!.escrowTicket)
    }
    
    func testSubmitUserConsentPoliciesWithUsernamePasswordEscrow_emptyPolicyArrya_error() {
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client onComplete - post consents - empty policy array..")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.submitUserConsentPolicies(Array<PGMConsentPolicy>(), withUsername: username, password: password,
            escrowTicket: "escrow1020", onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(8, clientResponse!.error.code, "Error needs to be of type .AuthConsentFlowError")
        XCTAssertEqual("No policy Ids included in request", clientResponse!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertEqual("escrow1020", clientResponse!.escrowTicket)
    }
    
    func testSubmitUserConsentPoliciesWithUsernamePasswordEscrow_userConsentRefusal_error() {
        
        var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: true, isReviewed: true)
        var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: false, isReviewed: true)
        var consentPolicies = Array<PGMConsentPolicy>()
        consentPolicies.append(consentPolicy1)
        consentPolicies.append(consentPolicy2)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client onComplete - post consents - consent refusal..")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.submitUserConsentPolicies(consentPolicies, withUsername: username, password: password,
            escrowTicket: "escrow1020", onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(3, clientResponse!.error.code, "Error needs to be of type .AuthRefuseConsentError")
        XCTAssertEqual("User refused consent", clientResponse!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertEqual("escrow1020", clientResponse!.escrowTicket)
        XCTAssertEqual(2, clientResponse!.consentPolicies.count)
        XCTAssertFalse(clientResponse!.consentPolicies[1].isConsented!)
        XCTAssertFalse(clientResponse!.consentPolicies[1].isReviewed!)
    }
    
    func testSubmitUserConsentPoliciesWithUsernamePasswordEscrow_success() {
        
        class MockConsentConnector: PGMConsentConnector {
            private override func runConsentSubmissionForPolicyIds(policies: [AnyObject]!, escrowTicket: String!, response: PGMAuthResponse!, onComplete: AuthenticationRequestComplete!) {
                println("completion handler in mock consent connector")
                onComplete(response)
            }
        }
        
        class MockAuthConnector: PGMAuthConnector {
            
            override func runAuthenticationRequestWithUsername(username: String!, password: String!,
                andResponse response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                    println("In mock function run login")
                    response.authContext = PGMAuthenticatedContext(accessToken: "token123",
                        refreshToken: "refreshToken456", andExpirationInterval: 1000)
                    completionHandler(response)
            }
            
            private override func runUserIdRequestWithResponse(response: PGMAuthResponse!, onComplete completionHandler: AuthConnectorRequestComplete!) {
                println("In mock function run userId")
                response.authContext.userIdentityId = "ffMyuser555"
                completionHandler(response)
            }
        }
        
        class MockKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return true
            }
        }
        
        let mockConnector = MockAuthConnector()
        let mockKeychainStorageManager = MockKeychainStorageManager()
        let mockConsentConnector = MockConsentConnector()
        
        authenticator.setConnector(mockConnector)
        authenticator.setKeychainStorageManager(mockKeychainStorageManager)
        authenticator.consentConnector = mockConsentConnector
        
        var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: true, isReviewed: true)
        var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: true, isReviewed: true)
        var consentPolicies = Array<PGMConsentPolicy>()
        consentPolicies.append(consentPolicy1)
        consentPolicies.append(consentPolicy2)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client onComplete - post consents - post consent success...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.submitUserConsentPolicies(consentPolicies, withUsername: username, password: password,
            escrowTicket: "escrow1020", onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNil(clientResponse!.error, "Shouldn't get error in success run")
        XCTAssertEqual("token123", clientResponse!.authContext.accessToken)
        XCTAssertEqual("refreshToken456", clientResponse!.authContext.refreshToken)
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn)
        XCTAssertEqual("ffMyuser555", clientResponse!.authContext.userIdentityId)
    }
    
    func testSubmitUserConsentPoliciesWithUsernamePasswordEscrow_errorFromConsentConnector_error() {
        
        class MockConsentConnector: PGMConsentConnector {
            private override func runConsentSubmissionForPolicyIds(policies: [AnyObject]!, escrowTicket: String!, response: PGMAuthResponse!, onComplete: AuthenticationRequestComplete!) {
                println("completion handler in mock consent connector - post consent error")
                response.error = PGMError.createErrorForErrorCode(.AuthConsentFlowError, andDescription: "Error in connector")
                onComplete(response)
            }
        }
        
        let mockConsentConnector = MockConsentConnector()
        
        authenticator.consentConnector = mockConsentConnector
        
        var consentPolicy1 = PGMConsentPolicy(policyId: "12345", consentUrl: "http://consent_1.com", isConsented: true, isReviewed: true)
        var consentPolicy2 = PGMConsentPolicy(policyId: "67890", consentUrl: "http://consent_2.com", isConsented: true, isReviewed: true)
        var consentPolicies = Array<PGMConsentPolicy>()
        consentPolicies.append(consentPolicy1)
        consentPolicies.append(consentPolicy2)
        
        var clientOnCompleteRan: Bool = false
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - post consents - post consent error...")
            clientOnCompleteRan = true
            clientResponse = authResponse
        }
        
        authenticator.submitUserConsentPolicies(consentPolicies, withUsername: username, password: password,
            escrowTicket: "escrow1020", onComplete: clientOnComplete)
        
        XCTAssertTrue(clientOnCompleteRan, "clientOnComplete was not executed")
        XCTAssertNotNil(clientResponse!.error, "Error returned from consent connector")
        XCTAssertEqual(8, clientResponse!.error.code, "Error type should be of type .AuthConsentFlowError")
        XCTAssertEqual("Error in connector", clientResponse!.error.userInfo?.values.first as String, "Wrong error msg")
        XCTAssertNil(clientResponse!.authContext, "Can't have auth context with consent connector error")
    }
    
    
    //MARK: logout tests
    
    func testLogoutUserWithAuthenticatedContext_missingUserId_error() {
        
        var response = authenticator.logoutUserWithAuthenticatedContext(nil)
        
        XCTAssertNil(response.authContext)
        XCTAssertNotNil(response.error, "Error should be returned for nil input")
        XCTAssertEqual(12, response.error.code, "Error type should be PGMAuthMissingUserIdError")
        
        var authContext = PGMAuthenticatedContext()
        
        response = authenticator.logoutUserWithAuthenticatedContext(authContext)
        
        XCTAssertNil(response.authContext)
        XCTAssertNotNil(response.error, "Error should be returned for nil input")
        XCTAssertEqual(12, response.error.code, "Error type should be PGMAuthMissingUserIdError")
        
        authContext.userIdentityId = ""
        
        response = authenticator.logoutUserWithAuthenticatedContext(authContext)
        
        XCTAssertNil(response.authContext)
        XCTAssertNotNil(response.error, "Error should be returned for nil input")
        XCTAssertEqual(12, response.error.code, "Error type should be PGMAuthMissingUserIdError")
    }
    
    func testLogoutUserWithAuthenticatedContext_unableToDeleteContext_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            private override func deleteAuthContextForIdentifier(identifier: String!) -> Bool {
                return false
            }
        }
        
        authenticator.setKeychainStorageManager(MockPGMAuthKeychainStorageManager())
        
        var authContext = PGMAuthenticatedContext()
        authContext.userIdentityId = "myUserIdentityId"
        
        var response = authenticator.logoutUserWithAuthenticatedContext(authContext)
        
        XCTAssertNil(response.authContext)
        XCTAssertNotNil(response.error, "Error should be returned when deleting from keychain fails")
        XCTAssertEqual(15, response.error.code, "Error type should be PGMAuthDeleteUserIdentityIDFromKeychain")
    }
    
    func testLogoutUserWithAuthenticatedContext_success() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            
            private override func deleteAuthContextForIdentifier(identifier: String!) -> Bool {
                return true
            }
        }
        
        authenticator.setKeychainStorageManager(MockPGMAuthKeychainStorageManager())
        
        var authContext = PGMAuthenticatedContext()
        authContext.userIdentityId = "myUserIdentityId"
        
        var response = authenticator.logoutUserWithAuthenticatedContext(authContext)
        
        XCTAssertNil(response.authContext)
        XCTAssertNil(response.error, "Error should be returned when deleting from keychain fails")
    }
    
    //MARK: forgot username tests
    func testForgotUsernameForEmailOnComplete_missingEmail_error() {
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - forgot username...")
            clientResponse = authResponse
        }
        
        authenticator.forgotUsernameForEmail(nil, onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(16, clientResponse!.error.code, "Error must be of type PGMAuthInvalidEmailError")
        
        clientResponse = nil
        authenticator.forgotUsernameForEmail("", onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(16, clientResponse!.error.code, "Error must be of type PGMAuthInvalidEmailError")
        
        clientResponse = nil
        authenticator.forgotUsernameForEmail("bademail.com", onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(16, clientResponse!.error.code, "Error must be of type PGMAuthInvalidEmailError")
    }
    
    func testForgotUsernameForEmailOnComplete_success() {
        
        class MockAuthConnector: PGMAuthConnector {
            private override func runForgotUsernameForEmail(email: String!, withResponse response: PGMAuthResponse!, onComplete: AuthenticationRequestComplete!) {
                onComplete(response)
            }
        }
        
        authenticator.setConnector(MockAuthConnector())
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            if (authResponse.error != nil) {
                println("Running client's onComplete - forgot username...Error!")
            } else {
                println("Running client's onComplete - forgot username...Success!")
            }
            clientResponse = authResponse
        }
        
        authenticator.forgotUsernameForEmail("a7@b.cc", onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse!.error)
        XCTAssertNil(clientResponse!.authContext)
    }
    
    //MARK: forgot password tests
    func testForgotPasswordForUsernameOnComplete_missingUsername_error() {
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - forgot password...")
            clientResponse = authResponse
        }
        
        authenticator.forgotPasswordForUsername(nil, onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(20, clientResponse!.error.code, "Error must be of type PGMAuthMissingUsernameError")
        
        clientResponse = nil
        authenticator.forgotPasswordForUsername("", onComplete: clientOnComplete)
        
        XCTAssertNotNil(clientResponse!.error)
        XCTAssertEqual(20, clientResponse!.error.code, "Error must be of type PGMAuthMissingUsernameError")
    }
    
    func testForgotPasswordForUsernameOnComplete_success() {
        
        class MockAuthConnector: PGMAuthConnector {
            private override func runForgotPasswordForUsername(username: String!, withResponse response: PGMAuthResponse!, onComplete completionHandler: AuthenticationRequestComplete!) {
                completionHandler(response)
            }
        }
        
        authenticator.setConnector(MockAuthConnector())
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - forgot password...")
            clientResponse = authResponse
        }
        
        authenticator.forgotPasswordForUsername("myUser", onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse!.error)
        XCTAssertNil(clientResponse!.authContext)
    }
    
    //MARK: obtaining current token - may involve refresh flow
    func testObtainCurrentTokenForAuthContext_error() {
        
        class MockAuthContextValidator: PGMAuthContextValidator {
            private override func provideCurrentTokenForAuthContext(authContext: PGMAuthenticatedContext!, environment: PGMEnvironment!, options userOptions: PGMAuthOptions!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var response = PGMAuthResponse()
                response.error = PGMError.createErrorForErrorCode(.AuthMissingContextError, andDescription: "Mock error desc")
                completionHandler(response)
            }
        }
        
        authenticator.authContextValidator = MockAuthContextValidator()
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - get current token...")
            clientResponse = authResponse
        }
        
        authenticator.obtainCurrentTokenForAuthContext(nil, onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse?.authContext)
        XCTAssertNotNil(clientResponse?.error)
        XCTAssertEqual(6, clientResponse!.error.code, "error must be of type PGMAuthMissingContextError")
        XCTAssertEqual("Mock error desc", clientResponse?.error.userInfo?.values.first as String)
    }
    
    func testObtainCurrentTokenForAuthContext_success() {
        
        class MockAuthContextValidator: PGMAuthContextValidator {
            private override func provideCurrentTokenForAuthContext(authContext: PGMAuthenticatedContext!, environment: PGMEnvironment!, options userOptions: PGMAuthOptions!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                var response = PGMAuthResponse()
                var context = PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 1000)
                context.userIdentityId = "ffabc"
                response.authContext = context
                completionHandler(response)
            }
        }
        
        authenticator.authContextValidator = MockAuthContextValidator()
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - get current token...")
            clientResponse = authResponse
        }
        
        authenticator.obtainCurrentTokenForAuthContext(nil, onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse?.error)
        XCTAssertNotNil(clientResponse?.authContext)
        XCTAssertEqual("mockToken", clientResponse!.authContext.accessToken)
        XCTAssertEqual("mockRefreshToken", clientResponse!.authContext.refreshToken)
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn)
        XCTAssertEqual("ffabc", clientResponse!.authContext.userIdentityId)
    }
    
    func testObtainCurrentTokenForExpiredAuthContext_error() {
        
        class MockAuthContextValidator: PGMAuthContextValidator {
            private override func provideCurrentTokenForExpiredAuthContext(authContext: PGMAuthenticatedContext!, environment: PGMEnvironment!, options userOptions: PGMAuthOptions!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var response = PGMAuthResponse()
                response.error = PGMError.createErrorForErrorCode(.AuthMissingContextError, andDescription: "Mock error desc")
                completionHandler(response)
            }
        }
        
        authenticator.authContextValidator = MockAuthContextValidator()
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - get current token...")
            clientResponse = authResponse
        }
        
        authenticator.obtainCurrentTokenForExpiredAuthContext(nil, onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse?.authContext)
        XCTAssertNotNil(clientResponse?.error)
        XCTAssertEqual(6, clientResponse!.error.code, "error must be of type PGMAuthMissingContextError")
        XCTAssertEqual("Mock error desc", clientResponse?.error.userInfo?.values.first as String)
    }
    
    func testObtainCurrentTokenForExpiredAuthContext_success() {
        
        class MockAuthContextValidator: PGMAuthContextValidator {
            private override func provideCurrentTokenForExpiredAuthContext(authContext: PGMAuthenticatedContext!, environment: PGMEnvironment!, options userOptions: PGMAuthOptions!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                var response = PGMAuthResponse()
                var context = PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 1000)
                context.userIdentityId = "ffabc"
                response.authContext = context
                completionHandler(response)
            }
        }
        
        authenticator.authContextValidator = MockAuthContextValidator()
        
        var clientResponse: PGMAuthResponse? = nil
        var clientOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            println("Running client's onComplete - get current token...")
            clientResponse = authResponse
        }
        
        authenticator.obtainCurrentTokenForExpiredAuthContext(nil, onComplete: clientOnComplete)
        
        XCTAssertNil(clientResponse?.error)
        XCTAssertNotNil(clientResponse?.authContext)
        XCTAssertEqual("mockToken", clientResponse!.authContext.accessToken)
        XCTAssertEqual("mockRefreshToken", clientResponse!.authContext.refreshToken)
        XCTAssertEqual(1000, clientResponse!.authContext.tokenExpiresIn)
        XCTAssertEqual("ffabc", clientResponse!.authContext.userIdentityId)
    }
}
