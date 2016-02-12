//
//  PGMFactoryTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/4/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMFactoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTypeCreation_verifyTypes() {
        var environment : AnyObject = PGMFactory.createEnvironmentWithType(PGMEnvironmentType.StagingEnv)
        XCTAssertNotNil(environment, "Created environment cannot be nil")
        XCTAssertTrue(environment is PGMEnvironment, "Needs to return PGMEnvironment type")
        
        var authenticator : AnyObject = PGMFactory.createAuthenticatorWithEnvironment(PGMEnvironment(),
            andOptions: PGMAuthOptions())
        XCTAssertNotNil(authenticator, "Created authenticator cannot be nil")
        XCTAssertTrue(authenticator is PGMAuthenticator, "Needs to return PGMAuthenticator type")
        
        var classroom : AnyObject = PGMFactory.createClassroom()
        XCTAssertNotNil(classroom, "Created classroom cannot be nil")
        XCTAssertTrue(classroom is PGMClassroom, "Needs to return PGMClassroom type")
    }
}
