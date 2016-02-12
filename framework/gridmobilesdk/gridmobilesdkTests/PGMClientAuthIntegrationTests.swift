//
//  PGMClientIntegrationTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/7/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMClientAuthIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: login integration tests
    
    func IgnoretestClientWithSimulatedEnv() {
        var gridClient = PGMClient(environmentType: .SimulatedEnv, andOptions: nil)
        
        var onComplete: AuthenticationRequestComplete =  {(PGMAuthResponse) -> () in
            
            if (PGMAuthResponse.error != nil) {
                println("Sim data - Executing completion block - error!")
            }else {
                println("Sim data - Executing completion block - success!!")
            }
            XCTAssertNotNil(PGMAuthResponse.authContext)
            XCTAssertNil(PGMAuthResponse.error)
            XCTAssertEqual(PGMAuthMockAccessToken, PGMAuthResponse.authContext.accessToken as String, "Mock access token should be set")
            XCTAssertEqual(PGMAuthMockRefreshToken, PGMAuthResponse.authContext.refreshToken as String, "Mock refresh token should be set")
            XCTAssertEqual(PGMAuthMockTokenExpiresIn, PGMAuthResponse.authContext.tokenExpiresIn, "Mock expires in should be set")
            XCTAssertEqual(PGMAuthMockUsername, PGMAuthResponse.authContext.username, "Mock username should be set")
            XCTAssertEqual(PGMAuthMockPiUserId, PGMAuthResponse.authContext.userIdentityId, "Mock Pi userId should be set")
        }
        
        gridClient.authenticator.authenticateWithUserName(PGMAuthMockUsername,
            andPassword: PGMAuthMockPassword, onComplete: onComplete)
        
        //verify keychain storage:
        var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(PGMAuthMockPiUserId)
        var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        
        println("Access token from keychain: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertEqual(PGMAuthMockAccessToken, retrievedContext.accessToken as String, "Mock access token should be set in keychain")
        XCTAssertEqual(PGMAuthMockRefreshToken, retrievedContext.refreshToken as String, "Mock refresh token should be set in keychain")
        XCTAssertEqual(PGMAuthMockTokenExpiresIn, retrievedContext.tokenExpiresIn, "Mock expires in should be set in keychain")
        XCTAssertEqual(PGMAuthMockUsername, retrievedContext.username, "Mock username should be set in keychain")
        XCTAssertEqual(PGMAuthMockPiUserId, retrievedContext.userIdentityId, "Mock Pi userId should be set in keychain")
    }
    
    func IgnoretestClientWithStagingEnv() {
        var username = "group12user"
        var password = "P@ssword1"
        var clientOptions = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "secret", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        var gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
        
        let expectation = expectationWithDescription("Auth expectation")
        
         var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block - error!")
                println("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo?.values.first as String)")
            }else {
                println("Executing completion block - success!!")
            }
            
            if (authResponse.authContext != nil) {
                XCTAssertNotNil(authResponse.authContext.accessToken, "Should have access token")
                XCTAssertNotNil(authResponse.authContext.refreshToken, "Should have refresh token")
                XCTAssertEqual("ffffffff5364096be4b06dc3168baa33", authResponse.authContext.userIdentityId, "Should be group12user id in Staging")
                XCTAssertEqual(username, authResponse.authContext.username, "Username must be \(username)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            expectation.fulfill()
        }
        
        gridClient.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: onComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        //verify keychain storage:
        var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier("ffffffff5364096be4b06dc3168baa33")
        var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        
        println("Access token from keychain - staging env: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertNotNil(retrievedContext.accessToken as String, "Access token from Staging should be set in keychain")
        XCTAssertNotNil(retrievedContext.refreshToken as String, "Refresh token from Staging should be set in keychain")
        XCTAssertNotNil(retrievedContext.tokenExpiresIn, "Expires in from Staging should be set in keychain")
        XCTAssertEqual("group12user", retrievedContext.username, "Staging username should be set in keychain")
        XCTAssertEqual("ffffffff5364096be4b06dc3168baa33", retrievedContext.userIdentityId, "Staging Pi userId should be set in keychain")
    }
    
    func IgnoretestClientWithProdEnv() {
        var username = "group12_user"
        var password = "P@ssword1"
        var clientOptions = PGMAuthOptions(clientId: "GgXYn6HjbT2CzKXm5jh9aIGC7htBNWk1",
            andClientSecret: "secret", andRedirectUrl: "http://piapi.openclass.com/pi_group12client")
        var gridClient = PGMClient(environmentType: .ProductionEnv, andOptions: clientOptions)
        
        let expectation = expectationWithDescription("Auth expectation")
        
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block - error!")
                println("Error is \(authResponse.error.description)")
            }else {
                println("Executing completion block - success!!")
            }
            
            if (authResponse.authContext != nil) {
                XCTAssertNotNil(authResponse.authContext.accessToken, "Should have access token")
                XCTAssertNotNil(authResponse.authContext.refreshToken, "Should have refresh token")
                XCTAssertEqual("ffffffff53b1a5c0e4b05ba6f1434b51", authResponse.authContext.userIdentityId, "Should be group12_user id in Prod")
                XCTAssertEqual(username, authResponse.authContext.username, "Username must be \(username)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            expectation.fulfill()
        }
        
        gridClient.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: onComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        //verify keychain storage:
        var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier("ffffffff53b1a5c0e4b05ba6f1434b51")
        var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        
        println("Access token from keychain - prod env: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertNotNil(retrievedContext.accessToken as String, "Access token from Prod should be set in keychain")
        XCTAssertNotNil(retrievedContext.refreshToken as String, "Refresh token from Prod should be set in keychain")
        XCTAssertNotNil(retrievedContext.tokenExpiresIn, "Expires in from Prod should be set in keychain")
        XCTAssertEqual("group12_user", retrievedContext.username, "Prod username should be set in keychain")
        XCTAssertEqual("ffffffff53b1a5c0e4b05ba6f1434b51", retrievedContext.userIdentityId, "Prod Pi userId should be set in keychain")
    }
    
    // MARK: consent integration tests
    
    //NOTE: make sure user mobilenotconsented2 in fact is missing consents, or this request will fail
    // in the first part of the test w/msg: "mobilenotconsented2 can login!"
    func IgnoretestClientConsentWithStagingEnv() {
        var username = "mobilenotconsented2"
        var password = "Password1"
        var clientOptions = PGMAuthOptions(clientId: "wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5",
            andClientSecret: "secret", andRedirectUrl: "http://int-piapi.stg-openclass.com/pi_group12client")
        var gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
        
        var escrowTicketFromGrid: String? = nil
        var consentPoliciesFromGrid: Array<PGMConsentPolicy>? = nil
        
        let expectation = expectationWithDescription("Consent expectation")
        
        var onComplete: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block - error!")
                println("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo?.values.first as String)")
            }else {
                println("Executing completion block - success!!")
            }
            
            if (authResponse.authContext == nil && authResponse.error != nil) {
                XCTAssertNil(authResponse.authContext, "Should have nil auth context for lack of consent")
                XCTAssertNotNil(authResponse.error)
                XCTAssertEqual(2, authResponse.error.code, "Should have AuthNoConsentError error type for user's lack of consent")
                
                if authResponse.error.code == 9 {
                    XCTAssert(false,"mobilenotconsented2 exceeded max attempts to express consents.")
                }
                
                if authResponse.error.code == 2 {
                    XCTAssertNotNil(authResponse.consentPolicies, "Should have consent policies.")
                    XCTAssertTrue(authResponse.consentPolicies.count > 0, "Should have at list one consent policy.")
                    XCTAssertNotNil(authResponse.escrowTicket, "Must have escrow ticket")
                    XCTAssertFalse(authResponse.consentPolicies[0].isConsented!, "isConsented must be set to false")
                    XCTAssertFalse(authResponse.consentPolicies[0].isReviewed!, "isReviewed must be set to false")
                    
                    escrowTicketFromGrid = authResponse.escrowTicket
                    consentPoliciesFromGrid = authResponse.consentPolicies as Array<PGMConsentPolicy>?
                }
            }
            else {
                XCTAssert(false,"mobilenotconsented2 can login!")
            }
            
            expectation.fulfill()
        }
        
        gridClient.authenticator.authenticateWithUserName(username, andPassword: password, onComplete: onComplete)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        println("Escrow ticket is: \(escrowTicketFromGrid)")
        
        if (consentPoliciesFromGrid != nil) {
            for currentPolicy in consentPoliciesFromGrid! {
                currentPolicy.isConsented = true
                currentPolicy.isReviewed = true
            }
        }
        
        //now we need to post and log in:
        
        let expectation2 = expectationWithDescription("Post consent expectation")
        
        var onCompleteConsentPost: AuthenticationRequestComplete =  {(authResponse) -> () in
            
            if (authResponse.error != nil) {
                println("Executing completion block for post consent - error!")
                println("Error code is: \(authResponse.error.code) and msg: \(authResponse.error.userInfo?.values.first as String)")
            }else {
                println("Executing completion block for post consent - success!!")
            }
            
            if (authResponse.authContext != nil) {
                XCTAssertNotNil(authResponse.authContext.accessToken, "Should have access token")
                XCTAssertNotNil(authResponse.authContext.refreshToken, "Should have refresh token")
                XCTAssertEqual("ffffffff53d03390e4b072d1b4b1a597", authResponse.authContext.userIdentityId, "Should be mobilenotconsented2 id in Staging")
                XCTAssertEqual(username, authResponse.authContext.username, "Username must be \(username)")
            }
            else {
                XCTAssert(false,"No auth context!")
            }
            
            expectation2.fulfill()
        }
        
        gridClient.authenticator.submitUserConsentPolicies(consentPoliciesFromGrid, withUsername: username, password: password, escrowTicket: escrowTicketFromGrid, onComplete: onCompleteConsentPost)
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
        
        //verify keychain storage:
        var storedData = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier("ffffffff53d03390e4b072d1b4b1a597")
        var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        
        println("Access token from keychain - staging env: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)")
        
        XCTAssertNotNil(retrievedContext.accessToken as String, "Access token from Staging should be set in keychain")
        XCTAssertNotNil(retrievedContext.refreshToken as String, "Refresh token from Staging should be set in keychain")
        XCTAssertNotNil(retrievedContext.tokenExpiresIn, "Expires in from Staging should be set in keychain")
        XCTAssertEqual("mobilenotconsented2", retrievedContext.username, "Staging username should be set in keychain")
        XCTAssertEqual("ffffffff53d03390e4b072d1b4b1a597", retrievedContext.userIdentityId, "Staging Pi userId should be set in keychain")
    }
}
