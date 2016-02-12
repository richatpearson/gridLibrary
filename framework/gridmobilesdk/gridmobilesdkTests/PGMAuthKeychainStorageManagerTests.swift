//
//  PGMAuthKeychainStorageManagerTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/21/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthKeychainStorageManagerTests: XCTestCase {
    
    var myToken = "12345"
    var myRefreshToken = "refresh12345"
    var myExpiresIn:Int = 2000
    var myUserId = "userId12345"
    var myUsername = "username12345"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStoreKeychainAuthenticatedContext_missingContext_error() {
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        
        var error: NSError? = nil
        var result = keychainStorageManager.storeKeychainAuthenticatedContext(nil, error: &error)
        
        XCTAssertNotNil(error, "Nil context returns an error")
        XCTAssertEqual(6, error!.code, "Error must be of type AuthMissingContextError")
        XCTAssertEqual(false, result, "Should return false with error condition")
    }
    
    func testStoreKeychainAuthenticatedContext_contextPresent_success() {
        
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        
        var authContext = self.createAuthContext()
        
        var error: NSError? = nil
        var result = keychainStorageManager.storeKeychainAuthenticatedContext(authContext, error: &error)
        
        XCTAssertNil(error, "No error with successful call")
        XCTAssertEqual(true, result, "Should return true with with successful call")
        
        /*var storedData = PGMSecureKeychainStorage.getValueForKey(myUserId);
        var retrievedContext = NSKeyedUnarchiver.unarchiveObjectWithData(storedData) as PGMAuthenticatedContext
        
        println("Access token from keychain: \(retrievedContext.accessToken) and refresh: \(retrievedContext.refreshToken), and expires in: \(retrievedContext.tokenExpiresIn), and username: \(retrievedContext.username), and user identity: \(retrievedContext.userIdentityId)") */
    }
    
    func createAuthContext() -> PGMAuthenticatedContext {
        
        var authContext = PGMAuthenticatedContext(accessToken: myToken, refreshToken: myRefreshToken, andExpirationInterval: 2000)
        authContext.userIdentityId = myUserId
        authContext.username = myUsername
        
        return authContext
    }
    
    func testRetrieveAuthContextForIdentifier_wrongIdentifier_nil() {
        
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        var result = keychainStorageManager.retrieveAuthContextForIdentifier("mybogusId")
        
        XCTAssertNil(result, "Nil should be returned for non-existing user id")
    }
    
    func testRetrieveAuthContextForIdentifier_nilIdentifier_nil() {
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        var result = keychainStorageManager.retrieveAuthContextForIdentifier(nil)
        
        XCTAssertNil(result, "Nil should be returned for nil user id")
    }
    
    func testRetrieveAuthContextForIdentifier_success() {
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        
        var authContext = self.createAuthContext()
        
        var error: NSError? = nil
        var storeResult = keychainStorageManager.storeKeychainAuthenticatedContext(authContext, error: &error)
        
        var readResult = keychainStorageManager.retrieveAuthContextForIdentifier(myUserId) as PGMAuthenticatedContext
        
        println("Read this access token from keychain: \(readResult.accessToken)")
        XCTAssertEqual(myUserId, readResult.userIdentityId)
        XCTAssertEqual(myToken, readResult.accessToken)
        XCTAssertEqual(myRefreshToken, readResult.refreshToken)
        XCTAssertEqual(myExpiresIn, readResult.tokenExpiresIn)
        XCTAssertEqual(myUsername, readResult.username)
        XCTAssertNotNil(readResult.creationDateInterval)
    }
    
    func testDeleteAuthContextForIdentifier_nilIdentifier_false() {
        
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        var deleteContextResult = keychainStorageManager.deleteAuthContextForIdentifier(nil)
        
        XCTAssertFalse(deleteContextResult)
    }
    
    func testDeleteAuthContextForIdentifier_wrongIdentifier_true() { //for non-existant identifier we return true
        
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        var deleteContextResult = keychainStorageManager.deleteAuthContextForIdentifier("bogusIdentifier")
        
        XCTAssertTrue(deleteContextResult)

    }
    
    func testDeleteAuthContextForIdentifier_success_true() {
        
        self.testRetrieveAuthContextForIdentifier_success() //we run this previous test to set up the scenario
        
        var keychainStorageManager = PGMAuthKeychainStorageManager()
        var deleteContextResult = keychainStorageManager.deleteAuthContextForIdentifier(myUserId)
        
        XCTAssertTrue(deleteContextResult)
        
        var readResult = keychainStorageManager.retrieveAuthContextForIdentifier(myUserId)
        
        XCTAssertNil(readResult, "Nil should be returned for non-existing user id")
    }
}
