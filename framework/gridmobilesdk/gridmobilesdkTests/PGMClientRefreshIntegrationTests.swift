//
//  PGMClientRefreshIntegrationTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 12/30/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import GRIDMobileSDK

class PGMClientRefreshIntegrationTests: XCTestCase {
    
    var username: String!
    var password: String!
    var clientOptions: PGMAuthOptions!
    var gridClient: PGMClient!
    var userPiId: String!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        username = "group12user"
        password = "P@ssword1"
        clientOptions = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "SAftAexlgpeSTZ7n", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        
        gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
        userPiId = "ffffffff5364096be4b06dc3168baa33"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func provideAuthContext() -> PGMAuthenticatedContext {
        let authExpectation = expectationWithDescription("Auth expectation")
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        let authOnComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                print("Providing context - Executing completion block - error!")
                print("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo.values.first as! String)")
            }else {
                print("Providing context - Executing completion block - success!!")
            }
            responseFromCompleteBlock = authResponse
            
            if (authResponse.authContext != nil) {
                print("Providing access token: \(authResponse.authContext.accessToken)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            authExpectation.fulfill()
        }
        
        gridClient.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: authOnComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        return responseFromCompleteBlock!.authContext
    }
    
    func IgnoretestRefreshToken_currentContext() {
        
        let origAuthContext = provideAuthContext()
        
        //validate the context
        let refreshExpectation = expectationWithDescription("Refresh expectation")
        
        var responseFromRefreshCompleteBlock: PGMAuthResponse? = nil
        let refreshOnComplete: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh - Executing completion block - success!!")
            }
            responseFromRefreshCompleteBlock = refreshResponse
            
            if (refreshResponse.authContext != nil) {
                print("Refresh - Access token is: \(refreshResponse.authContext.accessToken)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            refreshExpectation.fulfill()
        }
        
        let authContextValidator = PGMAuthContextValidator()
        authContextValidator.provideCurrentTokenForAuthContext(origAuthContext, environment: gridClient.environment,
            options: gridClient.options, onComplete: refreshOnComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        let refreshAuthContext = responseFromRefreshCompleteBlock!.authContext
        
        XCTAssertEqual(origAuthContext.accessToken, refreshAuthContext.accessToken, "access tokens should be the same with current context")
        XCTAssertEqual(origAuthContext.refreshToken, refreshAuthContext.refreshToken, "refresh tokens should be the same with current context")
    }
    
    func IgnoretestRefreshToken_expiredAccessToken_validRefreshToken() {
        
        let origAuthContext = provideAuthContext()
        
        let modifiedAuthContext = PGMAuthenticatedContext(accessToken: origAuthContext.accessToken,
            refreshToken: origAuthContext.refreshToken, andExpirationInterval: 1)
        
        modifiedAuthContext.userIdentityId = origAuthContext.userIdentityId
        modifiedAuthContext.username = origAuthContext.username
        
        let authContextData = NSKeyedArchiver.archivedDataWithRootObject(modifiedAuthContext)
        let isStored = PGMSecureKeychainStorage.storeKeychainData(authContextData, withIdentifier: modifiedAuthContext.userIdentityId)
        if (isStored) {
            print("Successfully updated the orig auth context")
        }
        
        sleep(2)
        
        //validate the modified context:
        let refreshExpectation = expectationWithDescription("Refresh expectation")
        
        var responseFromRefreshCompleteBlock: PGMAuthResponse? = nil
        let refreshOnComplete: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh - Executing completion block - success!!")
                print("Refresh - new access token is: \(refreshResponse.authContext.accessToken)")
            }
            responseFromRefreshCompleteBlock = refreshResponse
            
            refreshExpectation.fulfill()
        }
        
        let authContextValidator = PGMAuthContextValidator()
        
        authContextValidator.provideCurrentTokenForAuthContext(modifiedAuthContext, environment: gridClient.environment,
            options: gridClient.options, onComplete: refreshOnComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromRefreshCompleteBlock!.error)
        XCTAssertNotNil(responseFromRefreshCompleteBlock?.authContext)
        XCTAssertNotEqual(modifiedAuthContext.accessToken, responseFromRefreshCompleteBlock!.authContext.accessToken, "Should have a new set of tokens after refresh")
        XCTAssertNotEqual(modifiedAuthContext.refreshToken, responseFromRefreshCompleteBlock!.authContext.refreshToken, "Should have a new set of tokens after refresh")
        XCTAssertEqual(modifiedAuthContext.userIdentityId, responseFromRefreshCompleteBlock!.authContext.userIdentityId, "user identifier should remain the same")
        XCTAssertEqual(modifiedAuthContext.username, responseFromRefreshCompleteBlock!.authContext.username, "username should remain the same after refresh")
        
        //verify keychain storage:
        
        let storeManager = PGMAuthKeychainStorageManager()
        let retrievedContext = storeManager.retrieveAuthContextForIdentifier(modifiedAuthContext.userIdentityId) as PGMAuthenticatedContext
        
        print("Access token from keychain - staging env: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertEqual(responseFromRefreshCompleteBlock!.authContext.accessToken, retrievedContext.accessToken)
        XCTAssertEqual(responseFromRefreshCompleteBlock!.authContext.refreshToken, retrievedContext.refreshToken)
        XCTAssertEqual(1799, retrievedContext.tokenExpiresIn)
        XCTAssertEqual(username, retrievedContext.username)
        XCTAssertEqual(userPiId, retrievedContext.userIdentityId)
    }
    
    func IgnoretestRefreshToken_expiredRefreshToken_error() {
        
        let oldAuthContext = PGMAuthenticatedContext(accessToken: "kNbEBAQMA4tnc7tlZ1g49cpndMWn",
            refreshToken: "y2Y8PATHYvC0MjW5VNthFiyzi6a1gUIv", andExpirationInterval: 1)
        
        oldAuthContext.userIdentityId = userPiId
        oldAuthContext.username = username
        
        let authContextData = NSKeyedArchiver.archivedDataWithRootObject(oldAuthContext)
        let isStored = PGMSecureKeychainStorage.storeKeychainData(authContextData, withIdentifier: oldAuthContext.userIdentityId)
        if (isStored) {
            print("Successfully stored the old auth context")
        }
        
        XCTAssertNotNil(PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(oldAuthContext.userIdentityId))
        
        sleep(2)
        
        //validate the old context
        let refreshExpectation = expectationWithDescription("Refresh expectation")
        
        var responseFromRefreshCompleteBlock: PGMAuthResponse? = nil
        let refreshOnComplete: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh - Executing completion block - success!!")
            }
            responseFromRefreshCompleteBlock = refreshResponse
            
            refreshExpectation.fulfill()
        }
        
        let authContextValidator = PGMAuthContextValidator()
        
        authContextValidator.provideCurrentTokenForAuthContext(oldAuthContext, environment: gridClient.environment,
            options: gridClient.options, onComplete: refreshOnComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNotNil(responseFromRefreshCompleteBlock!.error)
        XCTAssertEqual(11, responseFromRefreshCompleteBlock!.error.code, "Error should be of type PGMAuthRefreshTokenExpiredError")
        XCTAssertNil(responseFromRefreshCompleteBlock?.authContext, "Should be nil context with expired refresh token")
        
        //validate data in keychain has been deleted:
        let storedOldData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(oldAuthContext.userIdentityId)
        
        XCTAssertNil(storedOldData, "Context should be deleted for expired refresh tokens")
    }
    
    //MARK: testing thread safety
    
    //TODO: see GRID Mobile Client test app - see spawning threads in view controller
    //RichFixRefreshRaceSandBox branch in git
    
    func IgnoretestRefreshToken_currentContext_concurrentRequests() {
        
        let origAuthContext = provideAuthContext()
        
        //validate the context
        let refreshExpectation = expectationWithDescription("Refresh expectation")
        let refreshExpectation2 = expectationWithDescription("Refresh expectation 2")
        
        var responseFromRefreshCompleteBlock: PGMAuthResponse? = nil
        let refreshOnComplete: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh - Executing completion block - success!!")
            }
            responseFromRefreshCompleteBlock = refreshResponse
            
            if (refreshResponse.authContext != nil) {
                print("Refresh - Access token is: \(refreshResponse.authContext.accessToken)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            refreshExpectation.fulfill()
        }
        
        var responseFromRefreshCompleteBlock2: PGMAuthResponse? = nil
        let refreshOnComplete2: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh 2 - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh 2 - Executing completion block - success!!")
            }
            responseFromRefreshCompleteBlock2 = refreshResponse
            
            if (refreshResponse.authContext != nil) {
                print("Refresh 2 - Access token is: \(refreshResponse.authContext.accessToken)")
            }
            else {
                XCTAssert(false,"No auth context - 2!")
            }
            
            refreshExpectation2.fulfill()
        }
        
        let authContextValidator = PGMAuthContextValidator()
        
        //authContextValidator.provideCurrentContextForUser(origAuthContext.userIdentityId, environment: gridClient.environment,
        //    options: gridClient.options, onComplete: refreshOnComplete)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            print("1: Runnig task to provide current context - on thread \(NSThread.currentThread())")
            authContextValidator.provideCurrentTokenForAuthContext(origAuthContext, environment: self.gridClient.environment, options: self.gridClient.options, onComplete: { (response) -> Void in
                    refreshOnComplete(response)
            })
        }
        
        NSThread.sleepForTimeInterval(0.002)
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            print("2. Runnig task to provide current context - on thread \(NSThread.currentThread())")
            authContextValidator.provideCurrentTokenForAuthContext(origAuthContext, environment: self.gridClient.environment, options: self.gridClient.options, onComplete: { (response) -> Void in
                    refreshOnComplete2(response)
            })
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        let refreshAuthContext = responseFromRefreshCompleteBlock!.authContext
        
        XCTAssertEqual(origAuthContext.accessToken, refreshAuthContext.accessToken, "access tokens should be the same with current context")
        XCTAssertEqual(origAuthContext.refreshToken, refreshAuthContext.refreshToken, "refresh tokens should be the same with current context")
        
        let refreshAuthContext2 = responseFromRefreshCompleteBlock2!.authContext
        
        XCTAssertEqual(origAuthContext.accessToken, refreshAuthContext2.accessToken, "access tokens should be the same with current context")
        XCTAssertEqual(origAuthContext.refreshToken, refreshAuthContext2.refreshToken, "refresh tokens should be the same with current context")
    }
    
    func IgnoretestRefreshToken_expiredAccessToken_validRefreshToken_concurrentRequests() {
        
        let origAuthContext = provideAuthContext()
        
        let modifiedAuthContext = PGMAuthenticatedContext(accessToken: origAuthContext.accessToken,
            refreshToken: origAuthContext.refreshToken, andExpirationInterval: 1)
        
        modifiedAuthContext.userIdentityId = origAuthContext.userIdentityId
        modifiedAuthContext.username = origAuthContext.username
        
        let authContextData = NSKeyedArchiver.archivedDataWithRootObject(modifiedAuthContext)
        let isStored = PGMSecureKeychainStorage.storeKeychainData(authContextData, withIdentifier: modifiedAuthContext.userIdentityId)
        if (isStored) {
            print("Successfully updated the orig auth context")
        }
        
        sleep(2)
        
        //validate the modified context:
        let refreshExpectation = expectationWithDescription("Refresh expectation")
        let refreshExpectation2 = expectationWithDescription("Refresh expectation 2")
        
        var responseFromRefreshCompleteBlock: PGMAuthResponse? = nil
        let refreshOnComplete: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh - Executing completion block - success!!")
                print("Refresh - new access token is: \(refreshResponse.authContext.accessToken)")
            }
            responseFromRefreshCompleteBlock = refreshResponse
            
            refreshExpectation.fulfill()
        }
        
        var responseFromRefreshCompleteBlock2: PGMAuthResponse? = nil
        let refreshOnComplete2: AuthenticationRequestComplete =  {(refreshResponse) -> () in
            
            if (refreshResponse.error != nil) {
                print("Refresh 2 - Executing completion block - error!")
                print("Error code is: \(refreshResponse.error.code) and msg: \(refreshResponse.error.userInfo.values.first as! String)")
            }else {
                print("Refresh 2 - Executing completion block - success!!")
            }
            responseFromRefreshCompleteBlock2 = refreshResponse
            
            if (refreshResponse.authContext != nil) {
                print("Refresh 2 - Access token is: \(refreshResponse.authContext.accessToken)")
            }
            else {
                XCTAssert(false,"No auth context - 2!")
            }
            
            refreshExpectation2.fulfill()
        }
        
        let authContextValidator = PGMAuthContextValidator()
        
        //authContextValidator.provideCurrentContextForUser(modifiedAuthContext.userIdentityId, environment: gridClient.environment,
        //    options: gridClient.options, onComplete: refreshOnComplete)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            print("1: Runnig task to provide current context - on thread \(NSThread.currentThread())")
            authContextValidator.provideCurrentTokenForAuthContext(modifiedAuthContext, environment: self.gridClient.environment, options: self.gridClient.options, onComplete: { (response) -> Void in
                    refreshOnComplete(response)
            })
        }
        
        NSThread.sleepForTimeInterval(0.005)
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            print("2. Runnig task to provide current context - on thread \(NSThread.currentThread())")
            authContextValidator.provideCurrentTokenForAuthContext(modifiedAuthContext, environment: self.gridClient.environment, options: self.gridClient.options, onComplete: { (response) -> Void in
                    refreshOnComplete2(response)
            })
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        XCTAssertNil(responseFromRefreshCompleteBlock!.error)
        XCTAssertNotNil(responseFromRefreshCompleteBlock?.authContext)
        XCTAssertNotEqual(modifiedAuthContext.accessToken, responseFromRefreshCompleteBlock!.authContext.accessToken, "Should have a new set of tokens after refresh")
        XCTAssertNotEqual(modifiedAuthContext.refreshToken, responseFromRefreshCompleteBlock!.authContext.refreshToken, "Should have a new set of tokens after refresh")
        XCTAssertEqual(modifiedAuthContext.userIdentityId, responseFromRefreshCompleteBlock!.authContext.userIdentityId, "user identifier should remain the same")
        XCTAssertEqual(modifiedAuthContext.username, responseFromRefreshCompleteBlock!.authContext.username, "username should remain the same after refresh")
        
        XCTAssertNil(responseFromRefreshCompleteBlock2!.error)
        XCTAssertNotNil(responseFromRefreshCompleteBlock2?.authContext)
        XCTAssertEqual(responseFromRefreshCompleteBlock2!.authContext.accessToken, responseFromRefreshCompleteBlock!.authContext.accessToken, "2nd request should have the same token as the 1st request")
        XCTAssertEqual(responseFromRefreshCompleteBlock2!.authContext.refreshToken, responseFromRefreshCompleteBlock!.authContext.refreshToken, "Should have a new set of tokens after refresh")
        XCTAssertEqual(responseFromRefreshCompleteBlock2!.authContext.userIdentityId, responseFromRefreshCompleteBlock!.authContext.userIdentityId, "user identifier should remain the same")
        XCTAssertEqual(responseFromRefreshCompleteBlock2!.authContext.username, responseFromRefreshCompleteBlock!.authContext.username, "username should remain the same after refresh")
        
        //verify keychain storage:
        //var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier("ffffffff5364096be4b06dc3168baa33")
        //var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        let storeManager = PGMAuthKeychainStorageManager()
        let retrievedContext = storeManager.retrieveAuthContextForIdentifier(modifiedAuthContext.userIdentityId) as PGMAuthenticatedContext
        
        print("Access token from keychain - staging env: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertEqual(responseFromRefreshCompleteBlock!.authContext.accessToken, retrievedContext.accessToken)
        XCTAssertEqual(responseFromRefreshCompleteBlock!.authContext.refreshToken, retrievedContext.refreshToken)
        XCTAssertEqual(1799, retrievedContext.tokenExpiresIn)
        XCTAssertEqual(username, retrievedContext.username)
        XCTAssertEqual(userPiId, retrievedContext.userIdentityId)
    }
}
