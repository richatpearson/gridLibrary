//
//  PGMAuthFactoryTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/6/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthFactoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTypeCreation_verifyTypes() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var authConnector: AnyObject = PGMAuthFactory.createAuthConnectorWithEnvironment(env, andClientOptions: PGMAuthOptions())
        
        XCTAssertNotNil(authConnector, "Auth connector created in factory should not be nil")
        XCTAssertTrue(authConnector is PGMAuthConnector, "The correct type is PGMAuthConnector")
        XCTAssertNotNil((authConnector as PGMAuthConnector).environment)
        XCTAssertNotNil((authConnector as PGMAuthConnector).clientOptions)
        
        var authConnectorSerializer: AnyObject = PGMAuthFactory.createAuthConnectorSerializer()
        XCTAssertNotNil(authConnectorSerializer)
        XCTAssertTrue(authConnectorSerializer is PGMAuthConnectorSerializer, "must be of type PGMAuthConnectorSerializer")
        
        var mockDataProvider: AnyObject = PGMAuthFactory.createAuthMockDataProvider()
        XCTAssertNotNil(mockDataProvider)
        XCTAssertTrue(mockDataProvider is PGMAuthMockDataProvider, "must be of type PGMAuthMockDataProvider")
        
        var coreNetworkRequester: AnyObject = PGMAuthFactory.createCoreNetworkRequester()
        XCTAssertNotNil(coreNetworkRequester)
        XCTAssertTrue(coreNetworkRequester is PGMCoreNetworkRequester, "must be of type PGMCoreNetworkRequester")
        
        var authKeychainStorageManager: AnyObject = PGMAuthFactory.createAuthKeychainStorageManager()
        XCTAssertNotNil(authKeychainStorageManager)
        XCTAssertTrue(authKeychainStorageManager is PGMAuthKeychainStorageManager, "must be of type PGMAuthKeychainStorageManager")
        
        var consentConnector: AnyObject = PGMAuthFactory.createConsentConnectorWithEnvironment(env)
        XCTAssertNotNil(consentConnector)
        XCTAssertTrue(consentConnector is PGMConsentConnector, "must but of type PGMConsentConnector")
        
        var consentSerializer: AnyObject = PGMAuthFactory.createConsentSerializer()
        XCTAssertNotNil(consentSerializer)
        XCTAssertTrue(consentSerializer is PGMConsentSerializer, "must but of type PGMConsentSerializer")
    }
}
