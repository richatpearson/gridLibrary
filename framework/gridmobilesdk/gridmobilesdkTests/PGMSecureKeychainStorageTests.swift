//
//  PGMSecureKeychainStorageTests.swift
//  gridmobilesdk
//
//  Created by Seals, Morris D on 11/20/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMSecureKeychainStorageTests: XCTestCase {

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    
    // These tests relate to the default group Keychain access.
    
    func testSetValueOnce() {
        
        var user1KeyString:     String?     =   "jane_doe"
        
        var user1ValueString:   String?     =   "secret-password"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier: user1KeyString) )
    }

    func testSetValueMultipleTimes() {
        
        var user1KeyString:     String?     =   "john_doe"
        
        var user1ValueString:   String?     =   "secret-password-john"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
    }
    
    func testSetValueGetValueOnce() {
        
        var user1KeyString:     String?     =   "mary_jane"
        
        var user1ValueString:   String?     =   "secret-password-mary"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
    }
    
    func testSetValueGetValueMultipleTimes() {
        
        var user1KeyString:     String?     =   "jack_smith"
        
        var user1ValueString:   String?     =   "secret-password-jack"
        
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
    }
    
    func testSetValueGetValueMultipeUsers() {
        
        var user1KeyString:     String?     =   "bob_brown"
        var user1ValueString:   String?     =   "secret-password-bob"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        var user2KeyString:     String?     =   "ken_brown"
        var user2ValueString:   String?     =   "secret-password2-ken"
        var user2ValueData:     NSData?     =   user2ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user2ValueData, withIdentifier: user2KeyString ) )
        XCTAssertEqual( user2ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user2KeyString) );

        var user3KeyString:     String?     =   "betty_brown"
        var user3ValueString:   String?     =   "secret-password-betty"
        var user3ValueData:     NSData?     =   user3ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user3ValueData, withIdentifier: user3KeyString ) )
        XCTAssertEqual( user3ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user3KeyString) );
        
        var user4KeyString:     String?     =   "kurt_brown"
        var user4ValueString:   String?     =   "secret-password-kurt"
        var user4ValueData:     NSData?     =   user4ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user4ValueData, withIdentifier: user4KeyString ) )
        XCTAssertEqual( user4ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user4KeyString) );

    }

    func testSetValueGetValueDeleteKey() {
        
        var user1KeyString:     String?     =   "kenny_jones"
        var user1ValueString:   String?     =   "secret-password-kenny"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
    }

    func testSetValueGetValueDeleteKeyMultipleTimes() {
        
        var user1KeyString:     String?     =   "jerry_smith"
        var user1ValueString:   String?     =   "secret-password-jerry"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier: user1KeyString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(  user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(      user1KeyString) );

        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(  user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(      user1KeyString) );

        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(  user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(      user1KeyString) );

        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(  user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(      user1KeyString) );
    }
    
    func testDeleteNonExistentKeyOnce() {
        
        var user1KeyString:     String?     =   "non-existent-key1"
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
    }
    
    func testDeleteNonExistentKeyMultipleTimes() {
        
        var user1KeyString:     String?     =   "non-existent-key2"
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(user1KeyString) )
    }
   
    func testAssertNilForNonExistentKeyOnce() {
        
        var user1KeyString:     String?     =   "non-existent-key3"

        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) )
    }
    
    func testAssertNilForNonExistentKeyMultipleTimes() {
        
        var user1KeyString:     String?     =   "non-existent-key3"
        
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(user1KeyString) )
    }


    
    
    // These tests relate to integrator specified group Keychain access.
    
    func testSetValueOnceForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "jane_doe"
        
        var user1ValueString:   String?     =   "secret-password"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier:       user1KeyString,     forGroup: customGroupString) )
    }
    
    func testSetValueMultipleTimesForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "john_doe"
        
        var user1ValueString:   String?     =   "secret-password-john"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier:       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier:       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier:       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData(user1ValueData, withIdentifier:       user1KeyString,     forGroup: customGroupString) )
    }
    
    
    func testSetValueGetValueOnceForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "mary_jane"
        
        var user1ValueString:   String?     =   "secret-password-mary"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
    }
    
    func testSetValueGetValueMultipleTimesForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "jack_smith"
        
        var user1ValueString:   String?     =   "secret-password-jack"
        
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString ) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
    }

    func testSetValueGetValueMultipeUsersForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "bob_brown"
        var user1ValueString:   String?     =   "secret-password-bob"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        
        var user2KeyString:     String?     =   "ken_brown"
        var user2ValueString:   String?     =   "secret-password2-ken"
        var user2ValueData:     NSData?     =   user2ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user2ValueData, withIdentifier:      user2KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user2ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user2KeyString,     forGroup: customGroupString) );
        
        var user3KeyString:     String?     =   "betty_brown"
        var user3ValueString:   String?     =   "secret-password-betty"
        var user3ValueData:     NSData?     =   user3ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user3ValueData, withIdentifier:      user3KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user3ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user3KeyString,     forGroup: customGroupString) );
        
        var user4KeyString:     String?     =   "kurt_brown"
        var user4ValueString:   String?     =   "secret-password-kurt"
        var user4ValueData:     NSData?     =   user4ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user4ValueData, withIdentifier:      user4KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user4ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user4KeyString,     forGroup: customGroupString) );
        
    }
    
    func testSetValueGetValueDeleteKeyForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "kenny_jones"
        var user1ValueString:   String?     =   "secret-password-kenny"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) );
    }
    
    func testSetValueGetValueDeleteKeyMultipleTimesForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "jerry_smith"
        var user1ValueString:   String?     =   "secret-password-jerry"
        var user1ValueData:     NSData?     =   user1ValueString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        XCTAssertTrue( PGMSecureKeychainStorage.storeKeychainData( user1ValueData, withIdentifier:      user1KeyString,     forGroup: customGroupString) )
        XCTAssertEqual( user1ValueData!, PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(   user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) );
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) );
    }
    
    func testDeleteNonExistentKeyOnceForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "non-existent-key1"
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
    }
    
    func testDeleteNonExistentKeyMultipleTimesForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "non-existent-key2"
        
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
        XCTAssertTrue( PGMSecureKeychainStorage.deleteKeychainDataWithIdentifier(                       user1KeyString,     forGroup: customGroupString) )
    }
    
    func testAssertNilForNonExistentKeyOnceForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "non-existent-key3"
        
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) )
    }
    
    func testAssertNilForNonExistentKeyMultipleTimesForGroup() {
        
        var customGroupString:  String?     =   "group_abc"
        
        var user1KeyString:     String?     =   "non-existent-key3"
        
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) )
        XCTAssertNil( PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(                      user1KeyString,     forGroup: customGroupString) )
    }

    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    
    
    
}

























