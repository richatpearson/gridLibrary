//
//  PGMAuthContextValidatorTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/30/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthContextValidatorTests: XCTestCase {
    
    var testAuthContext: PGMAuthenticatedContext!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testAuthContext = PGMAuthenticatedContext(accessToken: "myAccessToken", refreshToken: "myRefreshToken",
            andExpirationInterval: 1000)
        testAuthContext.userIdentityId = "mockUserId"
        testAuthContext.username = "mockUser"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAuthContextValidatorInit() {
        var contextValidator: AnyObject? = nil
        contextValidator = PGMAuthContextValidator()
        
        XCTAssertNotNil(contextValidator)
        XCTAssertTrue(contextValidator is PGMAuthContextValidator)
        XCTAssertNotNil((contextValidator! as PGMAuthContextValidator).keychainStorageManager)
    }
    
    //MARK: provideCurrentContextForUser tests
    func testProvideCurrentTokenForAuthContext_emptyAuthContext_error() {
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = tokenRefreshResponse
        }
        
        var authContextValidator = PGMAuthContextValidator()
        
        authContextValidator.provideCurrentTokenForAuthContext(nil, environment: nil,
            options: nil, onComplete: currentContextCompletionHandler)
        
        XCTAssertNil(responseFromCompleteBlock?.authContext, "auth context should be nil when no user is provided")
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(6, responseFromCompleteBlock!.error.code, "error must be of type PGMAuthMissingContextError")
    }
    
    func testProvideCurrentTokenForAuthContext_emptyUserId_error() {
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = tokenRefreshResponse
        }
        
        var authContextValidator = PGMAuthContextValidator()
        
        authContextValidator.provideCurrentTokenForAuthContext(PGMAuthenticatedContext(), environment: nil,
            options: nil, onComplete: currentContextCompletionHandler)
        
        XCTAssertNil(responseFromCompleteBlock?.authContext, "auth context should be nil when no user is provided")
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(12, responseFromCompleteBlock!.error.code, "error must be of type PGMAuthMissingUserIdError")
    }
    
    func testProvideCurrentTokenForAuthContext_loggedOutUser_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                return nil
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(10, responseFromCompleteBlock!.error.code, "error should be of type PGMAuthUserLoggedOutError")
    }
    
    func testProvideCurrentTokenForAuthContext_currentToken_success() {
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myToken", refreshToken: "myRefreshToken", andExpirationInterval: 20)
                authContext.userIdentityId = identifier
                authContext.username = "myMockUsername"
                
                return authContext
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual("myToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual("myMockUsername", responseFromCompleteBlock!.authContext.username)
        XCTAssertEqual(20, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext.creationDateInterval)
    }
    
    func testProvideCurrentTokenForAuthContext_expiredToken_success() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myToken", refreshToken: "myRefreshToken", andExpirationInterval: 0)
                authContext.userIdentityId = identifier
                authContext.username = "myMockUsername"
                
                return authContext
            }
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return true
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var authContext = PGMAuthenticatedContext(accessToken: "myNewToken", refreshToken: "myNewRefreshToken", andExpirationInterval: 10)
                response.authContext = authContext
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual("myNewToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myNewRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual("myMockUsername", responseFromCompleteBlock!.authContext.username)
        XCTAssertEqual(10, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext.creationDateInterval)
    }
    
    func testProvideCurrentTokenForAuthContext_expiredTokenCantStoreInKeychain_success() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myToken", refreshToken: "myRefreshToken", andExpirationInterval: 0)
                authContext.userIdentityId = identifier
                authContext.username = "myMockUsername"
                
                return authContext
            }
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return false //can't store in keychain
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var authContext = PGMAuthenticatedContext(accessToken: "myNewToken", refreshToken: "myNewRefreshToken", andExpirationInterval: 10)
                response.authContext = authContext
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(7, responseFromCompleteBlock!.error.code, "error type should be PGMUnableToStoreContextInKeychainError")
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual("myNewToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myNewRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual("myMockUsername", responseFromCompleteBlock!.authContext.username)
        XCTAssertEqual(10, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext.creationDateInterval)
    }
    
    func testProvideCurrentTokenForAuthContext_expiredTokenErrorInConnector_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myToken", refreshToken: "myRefreshToken", andExpirationInterval: 0)
                authContext.userIdentityId = identifier
                authContext.username = "myMockUsername"
                
                return authContext
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                response.error = PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Mock refresh token error.")
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "error type should be PGMCoreNetworkCallError - set in mocked function")
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testProvideCurrentTokenForAuthContext_expiredToken_expiredRefreshToken_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myToken", refreshToken: "myRefreshToken", andExpirationInterval: 0)
                authContext.userIdentityId = identifier
                authContext.username = "myMockUsername"
                
                return authContext
            }
            
            private override func deleteAuthContextForIdentifier(identifier: String!) -> Bool {
                return true
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                response.error = PGMError.createErrorForErrorCode(.AuthRefreshTokenExpiredError, andDescription: "Mock expired refresh token error.")
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentContextCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(11, responseFromCompleteBlock!.error.code, "error type should be PGMAuthRefreshTokenExpiredError - set in mocked function")
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    //MARK: provideCurrentTokenForExpiredAuthContext tests:
    
    func testProvideCurrentTokenForExpiredAuthContext_emptyAuthContext_error() {
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentContextCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = tokenRefreshResponse
        }
        
        var authContextValidator = PGMAuthContextValidator()
        
        //auth context is nil:
        authContextValidator.provideCurrentTokenForExpiredAuthContext(nil, environment: nil,
            options: nil, onComplete: currentContextCompletionHandler)
        
        XCTAssertNil(responseFromCompleteBlock?.authContext, "auth context should be nil when no user is provided")
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(6, responseFromCompleteBlock!.error.code, "error must be of type PGMAuthMissingContextError")
        
        //userIdentityId is missing:
        responseFromCompleteBlock = nil
        var authContext = PGMAuthenticatedContext()
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(authContext, environment: nil,
            options: nil, onComplete: currentContextCompletionHandler)
        
        XCTAssertNil(responseFromCompleteBlock?.authContext, "auth context should be nil when no user is provided")
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(12, responseFromCompleteBlock!.error.code, "error must be of type PGMAuthMissingUserIdError")
        
        //access token is missing:
        responseFromCompleteBlock = nil
        authContext.userIdentityId = "mockUserId"
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(authContext, environment: nil,
            options: nil, onComplete: currentContextCompletionHandler)
        
        XCTAssertNil(responseFromCompleteBlock?.authContext, "auth context should be nil when no user is provided")
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(23, responseFromCompleteBlock!.error.code, "error must be of type PGMAuthMissingAccessTokenInContextError")
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_loggedOutUser_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                return nil
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(10, responseFromCompleteBlock!.error.code, "error should be of type PGMAuthUserLoggedOutError")
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_newerTokenInStore_success() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myNewerToken", refreshToken: "myNewerRefreshToken", andExpirationInterval: 100)
                authContext.userIdentityId = identifier
                authContext.username = "mockUser"
                
                return authContext
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if (tokenRefreshResponse.error != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual("myNewerToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myNewerRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual(100, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual(testAuthContext.username, responseFromCompleteBlock!.authContext.username)
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_sameTokenInStore_successInRefresh() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myAccessToken", refreshToken: "myRefreshToken", andExpirationInterval: 1000)
                authContext.userIdentityId = identifier
                authContext.username = "mockUser"
                
                return authContext
            }
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return true
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var authContext = PGMAuthenticatedContext(accessToken: "myNewToken", refreshToken: "myNewRefreshToken", andExpirationInterval: 10)
                response.authContext = authContext
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual("myNewToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myNewRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual(testAuthContext.username, responseFromCompleteBlock!.authContext.username)
        XCTAssertEqual(10, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext.creationDateInterval)
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_sameTokenInStore_CantStoreInKeychain_success() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myAccessToken", refreshToken: "myRefreshToken", andExpirationInterval: 1000)
                authContext.userIdentityId = identifier
                authContext.username = "mockUser"
                
                return authContext
            }
            
            private override func storeKeychainAuthenticatedContext(context: PGMAuthenticatedContext!, error: NSErrorPointer) -> Bool {
                return false //can't store in keychain
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                var authContext = PGMAuthenticatedContext(accessToken: "myNewToken", refreshToken: "myNewRefreshToken", andExpirationInterval: 10)
                response.authContext = authContext
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(7, responseFromCompleteBlock!.error.code, "error type should be PGMUnableToStoreContextInKeychainError")
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual(testAuthContext.userIdentityId, responseFromCompleteBlock!.authContext.userIdentityId)
        XCTAssertEqual("myNewToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("myNewRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual(testAuthContext.username, responseFromCompleteBlock!.authContext.username)
        XCTAssertEqual(10, responseFromCompleteBlock!.authContext.tokenExpiresIn)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext.creationDateInterval)
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_sameTokenInStore_ErrorInConnector_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myAccessToken", refreshToken: "myRefreshToken", andExpirationInterval: 1000)
                authContext.userIdentityId = identifier
                authContext.username = "mockUser"
                
                return authContext
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                response.error = PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Mock refresh token error.")
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "error type should be PGMCoreNetworkCallError - set in mocked function")
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testProvideCurrentTokenForExpiredAuthContext_sameTokenInStore_expiredRefreshToken_error() {
        
        class MockPGMAuthKeychainStorageManager: PGMAuthKeychainStorageManager {
            private override func retrieveAuthContextForIdentifier(identifier: String!) -> PGMAuthenticatedContext! {
                var authContext = PGMAuthenticatedContext(accessToken: "myAccessToken", refreshToken: "myRefreshToken",
                    andExpirationInterval: 1000)
                authContext.userIdentityId = identifier
                authContext.username = "mockUser"
                
                return authContext
            }
            
            private override func deleteAuthContextForIdentifier(identifier: String!) -> Bool {
                return true
            }
        }
        
        class MockPGMAuthConnector: PGMAuthConnector {
            private override func runRefreshTokenWithResponse(response: PGMAuthResponse!, authContext: PGMAuthenticatedContext!, onComplete completionHandler: AuthenticationRequestComplete!) {
                
                response.error = PGMError.createErrorForErrorCode(.AuthRefreshTokenExpiredError, andDescription: "Mock expired refresh token error.")
                completionHandler(response)
            }
        }
        
        var authContextValidator = PGMAuthContextValidator()
        authContextValidator.keychainStorageManager = MockPGMAuthKeychainStorageManager()
        authContextValidator.authConnector = MockPGMAuthConnector()
        
        let expectation = expectationWithDescription("Validate auth context expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var currentTokenCompletionHandler: AuthenticationRequestComplete =  {(tokenRefreshResponse) -> () in
            println("Running token refresh onComplete...")
            if ((tokenRefreshResponse.error) != nil) {
                println("...and error is: \(tokenRefreshResponse.error.userInfo?.values.first as String)")
            } else {
                println("Success!")
            }
            responseFromCompleteBlock = tokenRefreshResponse
            
            expectation.fulfill()
        }
        
        authContextValidator.provideCurrentTokenForExpiredAuthContext(testAuthContext, environment: nil, options: nil, onComplete: currentTokenCompletionHandler)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(11, responseFromCompleteBlock!.error.code, "error type should be PGMAuthRefreshTokenExpiredError - set in mocked function")
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
}
