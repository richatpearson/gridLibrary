//
//  PGMAuthConnectorSerializerTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthConnectorSerializerTests: XCTestCase {

    var serializer: PGMAuthConnectorSerializer? = nil
    
    override func setUp() {
        super.setUp()
        
        serializer = PGMAuthConnectorSerializer()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeserializeAuthenticationDataForResponse_nilData_error() {
        var response = serializer!.deserializeAuthenticationData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 24, "Error code must be of type PGMProviderReturnedNoDataError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeAuthenticationDataForResponse_cannotParse_error() {
        var htmlString: String = "<html><head></head><body><h2>Login - PIAPI Sample Login Page</h2></body></html>"
        var data: NSData = htmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 1, "Error code must be of type AuthInvalidCredentialsError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeAuthenticationDataForResponse_consentErrorNoMessage_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"\",\"code\": \"403-FORBIDDEN\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 0, "Error code must be of type AuthenticationError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
        
    }
    
    func testDeserializeAuthenticationDataForResponse_consentError_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"escrowTicket12345\",\"code\": \"403-FORBIDDEN\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 2, "Error code must be of type AuthNoConsentError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertEqual("escrowTicket12345", response.escrowTicket, "Escrow ticket was set to escrowTicket12345")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeAuthenticationDataForResponse_maxConsentRefusalError_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"Too many tickets for resource\",\"code\": \"404-NOT_FOUND\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 9, "Error code must be of type AuthMaxRefuseConsentError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeAuthenticationDataForResponse_expiredRefreshToken_error() {
        var jsonString: String = "{\"ErrorCode\": \"invalid_request\",\"Error\": \"Invalid Refresh Token\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 11, "Error code must be of type PGMAuthRefreshTokenExpiredError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeAuthenticationDataForResponse_success() {
        var jsonString: String = "{\"access_token\":\"\(PGMAuthMockAccessToken)\",\"refresh_token\":\"\(PGMAuthMockRefreshToken)\",\"expires_in\":\"\(PGMAuthMockTokenExpiresIn)\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNotNil(response.authContext)
        XCTAssertEqual(PGMAuthMockAccessToken, response.authContext.accessToken as String)
        XCTAssertEqual(PGMAuthMockRefreshToken, response.authContext.refreshToken as String)
        XCTAssertEqual(PGMAuthMockTokenExpiresIn, response.authContext.tokenExpiresIn)
    }
    
    func testDeserializeUserIdDataForResponse_nilData_error() {
        var response = serializer!.deserializeUserIdData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 0, "Error code must be of type AuthenticationError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeUserIdDataForResponse_parseError_error() {
        var htmlString: String = "<html><head></head><body><h2>Something</h2></body></html>"
        var data: NSData = htmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeUserIdData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 0, "Error code must be of type AuthenticationError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeUserIdDataForResponse_success() {
        var jsonString: String = "{\"status\":\"success\",\"data\":{\"id\":\"mockUsere4b085221e58ac55\",\"userName\":\"\(PGMAuthMockUsername)\",\"resetPassword\":false,\"identity\":{\"uri\":\"https://int-piapi.stg-openclass.com/v1/piapi-int/identities/\(PGMAuthMockPiUserId)\",\"id\":\"\(PGMAuthMockPiUserId)\"},\"createdAt\":\"2014-05-02T21:11:02+0000\",\"updatedAt\":\"2014-11-07T18:50:17+0000\"}}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeUserIdData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNotNil(response.authContext)
        XCTAssertEqual(PGMAuthMockPiUserId, response.authContext.userIdentityId)
    }
    
    func testDeserializeAuthenticationDataForResponse_invalidClientIdError_error() {
        var jsonString: String = "{\"code\": \"401\",\"message\": \"Invalid client Id\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeAuthenticationData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 14, "Error code must be of type AuthInvalidClientId")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertEqual("Invalid client Id", response.error.userInfo?.values.first as String)
        XCTAssertNil(response.authContext)
    }
    
    //MARK: forgot username tests
    func testDeserializeForgotUsernameDataForResponse_nilData_error() {
        var response = serializer!.deserializeForgotUsernameData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 24, "Error code must be of type PGMProviderReturnedNoDataError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameDataForResponse_noSuchEmail_error() {
        
        var jsonString: String = "{\"status\": \"error\",\"message\": \"No e-mail found\",\"code\": \"404-NOT_FOUND\", \"fault\": {\"detail\": {\"errorcode\": \"\(PGMAuthForgotUsernameEmailNotFound)\"}}}" //piui.noSuchEmailAddress
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotUsernameData(data, forResponse: PGMAuthResponse())
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 17, "Error code must be of type PGMAuthEmailNotFound")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameDataForResponse_unknownError_error() {
        
        var jsonString: String = "{\"status\": \"error\",\"message\": \"No e-mail found\",\"code\": \"404-NOT_FOUND\", \"fault\": {\"detail\": {\"errorcode\": \"piui.someOtherError\"}}}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotUsernameData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 18, "Error code must be of type PGMAuthUnknownForgotUsernameError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameDataForResponse_htmlSuccess_success() {
        
        var htmlString: String = "<html><head></head><body><h1>We Sent You An Email</h1><p> Check your email for your username and instructions on resetting your password.</p></body></html>"
        var data: NSData = htmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotUsernameData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameDataForResponse_differentJsonResponse_success() {
        
        var jsonString: String = "{\"status\": \"success\",\"message\": \"Sent e-mail...blah, blah\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotUsernameData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNil(response.authContext)
    }
    
    //MARK: forgot password tests
    func testDeserializeForgotUsernameData_nilData_error() {
        var response = serializer!.deserializeForgotPasswordData(nil, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 24, "Error code must be of type PGMProviderReturnedNoDataError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameData_noSuchUsername_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"Credentials not found for user\",\"code\": \"404-NOT_FOUND\", \"fault\": {\"detail\": {\"errorcode\": \"\(PGMAuthForgotPasswordNoSuchUsername)\"}}}" //piui.noSuchUsername
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotPasswordData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 21, "Error code must be of type PGMAuthUsernameNotFoundError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameData_tooManyAttempts_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"Credentials not found for user\",\"code\": \"404-NOT_FOUND\", \"fault\": {\"detail\": {\"errorcode\": \"\(PGMAuthForgotPasswordTooManyTickets)\"}}}" //piui.tooManytickets
        
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotPasswordData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 22, "Error code must be of type PGMAuthMaxForgotPasswordExceededError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameData_unknownError_error() {
        var jsonString: String = "{\"status\": \"error\",\"message\": \"No e-mail found\",\"code\": \"404-NOT_FOUND\", \"fault\": {\"detail\": {\"errorcode\": \"piui.someOtherError\"}}}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotPasswordData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error.code, 19, "Error code must be of type PGMAuthUnknownForgotPasswordError")
        XCTAssertTrue((response.error.userInfo?.values.first as String).utf16Count > 0, "Must return error message")
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameData_htmlSuccess_success() {
        var htmlString: String = "<html><head></head><body><h1>We Sent You An Email</h1><p> Check your email for your username and instructions on resetting your password.</p></body></html>"
        var data: NSData = htmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotPasswordData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNil(response.authContext)
    }
    
    func testDeserializeForgotUsernameData_someOtherJSONResponse_success() {
        var jsonString: String = "{\"status\": \"success\",\"message\": \"Sent e-mail to reset password...blah, blah\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var response = serializer!.deserializeForgotPasswordData(data, forResponse: PGMAuthResponse())
        
        XCTAssertNil(response.error)
        XCTAssertNil(response.authContext)
    }
}
