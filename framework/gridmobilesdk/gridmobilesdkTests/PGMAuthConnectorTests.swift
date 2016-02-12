//
//  PGMAuthenticatorConnectorTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/5/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMAuthConnectorTests: XCTestCase {

    var passedInResponse = PGMAuthResponse()
    
    var env: PGMEnvironment!
    var clientOptions: PGMAuthOptions!
    var authConnector: PGMAuthConnector!
    
    override func setUp() {
        super.setUp()
        
        passedInResponse.authContext =
            PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 100000)
        passedInResponse.authContext.username = "myuser"
        
        env = PGMEnvironment(environmentFromType: .StagingEnv)
        clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret", andRedirectUrl: "http://redirect.com")
        authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitAuthConnector() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        XCTAssertNotNil(authConnector, "Init should create auth connector object.")
        XCTAssertNotNil(authConnector.environment, "Env should be set")
        XCTAssertNotNil(authConnector.clientOptions, "Client options should be set")
        XCTAssert(authConnector.environment.currentEnvironment == .StagingEnv)
        XCTAssertEqual("clientId", authConnector.clientOptions.clientId)
        XCTAssertEqual("secret", authConnector.clientOptions.clientSecret)
        XCTAssertEqual("http://redirect.com", authConnector.clientOptions.redirectUrl)
        
        //checking dipendency injection of certain types:
        XCTAssertNotNil(authConnector.authConnectorSerilizer, "authConnectorSerializer should have been injected")
        XCTAssertNotNil(authConnector.authMockDataProvider, "authMockDataProvider should have been injected")
        XCTAssertNotNil(authConnector.networkRequester, "networkRequester should have been injected")
    }
    
    func testDependencyInjectionSetters() {
        var authConnector = PGMAuthConnector(environment: nil,andClientOptions: nil)

        authConnector.setConnectorSerializer(PGMAuthConnectorSerializer())
        XCTAssertNotNil(authConnector.authConnectorSerilizer)
        
        authConnector.setMockDataProvider(PGMAuthMockDataProvider())
        XCTAssertNotNil(authConnector.authMockDataProvider)
        
        authConnector.setCoreNetworkRequester(PGMCoreNetworkRequester())
        XCTAssertNotNil(authConnector.networkRequester)
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponseOnComplete_nilArguments_error() {
        var authConnector = PGMAuthConnector(environment: nil, andClientOptions: nil)
        
        //all args nil:
        var response: PGMAuthResponse? = nil
        
        var onCompleteNilEnv: AuthConnectorRequestComplete =  {(authResponseNilEnv) -> () in
            println("Running onComplete with nil env...")
            if (authResponseNilEnv.error != nil) {
                println("We have an error")
                println("Error description with nil env is: \(authResponseNilEnv.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNilEnv.error, "Error should be returned when env is nil")
            XCTAssertEqual(authResponseNilEnv.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseNilEnv.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        authConnector.runAuthenticationRequestWithUsername("username", password: "password", andResponse: response,
            onComplete: onCompleteNilEnv)
        
        //env not nil but set to NoEnvironment:
        authConnector.environment = PGMEnvironment(environmentFromType: .NoEnvironment);
        
        var onCompleteNoEnv: AuthConnectorRequestComplete =  {(authResponseNoEnv) -> () in
            println("Running onComplete with no env...")
            if (authResponseNoEnv.error != nil) {
                println("Error description with env as NoEnvironment is: \(authResponseNoEnv.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNoEnv.error, "Error should be returned when options are nil")
            XCTAssertEqual(authResponseNoEnv.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseNoEnv.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runAuthenticationRequestWithUsername("username", password: "password",
            andResponse: PGMAuthResponse(), onComplete: onCompleteNoEnv)
        
        //env set but options are nil:
        authConnector.environment = PGMEnvironment(environmentFromType: .StagingEnv);
        
        var onCompleteNilOptions: AuthConnectorRequestComplete =  {(authResponseOptionsNil) -> () in
            println("Running onComplete with nil Options...")
            if (authResponseOptionsNil.error != nil) {
                println("Error description with nil options is: \(authResponseOptionsNil.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseOptionsNil.error, "Error should be returned when options are nil")
            XCTAssertEqual(authResponseOptionsNil.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseOptionsNil.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runAuthenticationRequestWithUsername("username", password: "password",
            andResponse: PGMAuthResponse(), onComplete: onCompleteNilOptions)
        
        //env set, options set but options' properties are nil:
        authConnector.clientOptions = PGMAuthOptions()
        
        var onCompleteOptionsPropsNil: AuthConnectorRequestComplete =  {(authResponseOptionsPropNil) -> () in
            println("Running onComplete with Options prop nil...")
            if (authResponseOptionsPropNil.error != nil) {
                println("Error description with options props nil is: \(authResponseOptionsPropNil.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseOptionsPropNil.error, "Error should be returned when options are nil")
            XCTAssertEqual(authResponseOptionsPropNil.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseOptionsPropNil.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runAuthenticationRequestWithUsername("username", password: "password",
            andResponse: PGMAuthResponse(), onComplete: onCompleteOptionsPropsNil)
        
        //options' properties secret and redirect url are nil:
        authConnector.clientOptions.clientId = "id1234"
        
        var onCompleteSecretRedirNil: AuthConnectorRequestComplete =  {(authResponseSecretRedirNil) -> () in
            println("Running onComplete with secret and redirect as nil...")
            if (authResponseSecretRedirNil.error != nil) {
                println("Error description with options prop secret and redirect url nil is: \(authResponseSecretRedirNil.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseSecretRedirNil.error, "Error should be returned when options are nil")
            XCTAssertEqual(authResponseSecretRedirNil.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseSecretRedirNil.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runAuthenticationRequestWithUsername("username", password: "password",
            andResponse: PGMAuthResponse(), onComplete: onCompleteSecretRedirNil)
        
        //Only options' property redirect url is nil:
        authConnector.clientOptions.clientSecret = "mySecret"
        
        var onCompleteRedirNil: AuthConnectorRequestComplete =  {(authResponseRedirNil) -> () in
            println("Running onComplete with only redirect as nil...")
            if (authResponseRedirNil.error != nil) {
                println("Error description with only redirect url nil is: \(authResponseRedirNil.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseRedirNil.error, "Error should be returned when options are nil")
            XCTAssertEqual(authResponseRedirNil.error.code, 0, "Mock error code should be AuthenticationError")
            XCTAssertTrue((authResponseRedirNil.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runAuthenticationRequestWithUsername("username", password: "password",
            andResponse: PGMAuthResponse(), onComplete: onCompleteRedirNil)
    }
    
    func testRunUserIdRequestWithResponseOnComplete_nilArguments_error() {
        var authConnector = PGMAuthConnector(environment: PGMEnvironment(environmentFromType: .StagingEnv), andClientOptions: PGMAuthOptions())
        
        //Passed response is nil:
        var response: PGMAuthResponse? = nil
        
        var onCompleteNilResponse: AuthConnectorRequestComplete =  {(authResponseNilResponse) -> () in
            println("Running onComplete with nil token...")
            if (authResponseNilResponse.error != nil) {
                println("We have an error")
                println("Error description with nil token is: \(authResponseNilResponse.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNilResponse.error, "Error should be returned when passed in response is nil")
            XCTAssertEqual(authResponseNilResponse.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseNilResponse.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteNilResponse)
        
        //auth context nil:
        response = PGMAuthResponse()
        
        var onCompleteNilContext: AuthConnectorRequestComplete =  {(authResponseNilContext) -> () in
            println("Running onComplete with nil token...")
            if (authResponseNilContext.error != nil) {
                println("We have an error")
                println("Error description with nil context is: \(authResponseNilContext.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNilContext.error, "Error should be returned when context is nil")
            XCTAssertEqual(authResponseNilContext.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseNilContext.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteNilContext)
        
        //access token nil:
        response!.authContext = PGMAuthenticatedContext()
        
        var onCompleteNilToken: AuthConnectorRequestComplete =  {(authResponseNilToken) -> () in
            println("Running onComplete with nil token...")
            if (authResponseNilToken.error != nil) {
                println("We have an error")
                println("Error description with nil token is: \(authResponseNilToken.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNilToken.error, "Error should be returned when token is nil")
            XCTAssertEqual(authResponseNilToken.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseNilToken.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteNilToken)
        
        //empty access token:
        response!.authContext = nil
        response!.authContext = PGMAuthenticatedContext(accessToken: "", refreshToken: nil, andExpirationInterval: 0)
        
        var onCompleteEmptyToken: AuthConnectorRequestComplete =  {(authResponseEmptyToken) -> () in
            println("Running onComplete with nil token...")
            if (authResponseEmptyToken.error != nil) {
                println("We have an error")
                println("Error description with empty token is: \(authResponseEmptyToken.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseEmptyToken.error, "Error should be returned when token is empty")
            XCTAssertEqual(authResponseEmptyToken.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseEmptyToken.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteEmptyToken)
        
        //username nil;
        response!.authContext = nil
        response!.authContext = PGMAuthenticatedContext(accessToken: "12345", refreshToken: nil, andExpirationInterval: 0)
        
        var onCompleteNilUsername: AuthConnectorRequestComplete =  {(authResponseNilUsername) -> () in
            println("Running onComplete with nil token...")
            if (authResponseNilUsername.error != nil) {
                println("We have an error")
                println("Error description with nil username is: \(authResponseNilUsername.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseNilUsername.error, "Error should be returned when username is nil")
            XCTAssertEqual(authResponseNilUsername.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseNilUsername.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteNilUsername)
        
        //username is empty:
        response!.authContext.username = ""
        
        var onCompleteEmptyUsername: AuthConnectorRequestComplete =  {(authResponseEmptyUsername) -> () in
            println("Running onComplete with nil token...")
            if (authResponseEmptyUsername.error != nil) {
                println("We have an error")
                println("Error description with username username is: \(authResponseEmptyUsername.error.userInfo?.values.first as String)")
            }
            XCTAssertNotNil(authResponseEmptyUsername.error, "Error should be returned when username is empty")
            XCTAssertEqual(authResponseEmptyUsername.error.code, 5, "Mock error code should be AuthUserIdError")
            XCTAssertTrue((authResponseEmptyUsername.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
        }
        
        authConnector.runUserIdRequestWithResponse(response, onComplete: onCompleteEmptyUsername)
    }
    
    //Mock of PGMAuthMockDataProvider - factored out to share for multiple test calls
    class mockAuthDataProvider: PGMAuthMockDataProvider {
        override func provideTokenWithUsername(username: String!, password: String!) -> NSData! {
            var authJSONString = "{\"a\":\"b\"}"
            return authJSONString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        override func provideUserIdentityId() -> NSData! {
            var userIdJSONString = "{\"c\":\"d\"}"
            return userIdJSONString.dataUsingEncoding(NSUTF8StringEncoding)
        }
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_simulated_success() {
        var env = PGMEnvironment(environmentFromType: .SimulatedEnv)
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: nil)
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                let authContext = PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 100000)
                response.authContext = authContext
                return response
            }
        }
        
        let mockDataProvider = mockAuthDataProvider()
        let mockSerializer = mockAuthConnectorSerializer()
        
        authConnector.setMockDataProvider(mockDataProvider)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("access token is \(authResponse.authContext.accessToken)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertEqual("mockToken", responseFromCompleteBlock!.authContext.accessToken, "Mock access token should be set to mockToken")
        XCTAssertEqual("mockRefreshToken", responseFromCompleteBlock!.authContext.refreshToken, "Mock refresh token should be set to mockRefreshToken")
        XCTAssertEqual(100000, responseFromCompleteBlock!.authContext.tokenExpiresIn, "Mock expires in should be set to 100000")
        XCTAssertEqual("myuser", responseFromCompleteBlock!.authContext.username, "Mock username should be set to myuser")
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_simulated_errorParsingAuthData() {
        var env = PGMEnvironment(environmentFromType: .SimulatedEnv)
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: nil)
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockError")
                return response
            }
        }
        
        let mockDataProvider = mockAuthDataProvider()
        let mockSerializer = mockAuthConnectorSerializer()
        
        authConnector.setMockDataProvider(mockDataProvider)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be .AuthenticationError")
        XCTAssertEqual("mockError", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Error desc should be mockError")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_simulated_success() {
        var env = PGMEnvironment(environmentFromType: .SimulatedEnv)
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: nil)
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeUserIdData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
            response.authContext.userIdentityId = "ffmockUserId"
            return response
            }
        }
        
        let mockDataProvider = mockAuthDataProvider()
        let mockSerializer = mockAuthConnectorSerializer()
        
        authConnector.setMockDataProvider(mockDataProvider)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("access token is \(authResponse.authContext.accessToken)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertEqual("mockToken", responseFromCompleteBlock!.authContext.accessToken, "Mock access token should be set to mockToken")
        XCTAssertEqual("mockRefreshToken", responseFromCompleteBlock!.authContext.refreshToken, "Mock refresh token should be set to mockRefreshToken")
        XCTAssertEqual(100000, responseFromCompleteBlock!.authContext.tokenExpiresIn, "Mock expires in should be set to 100000")
        XCTAssertEqual("myuser", responseFromCompleteBlock!.authContext.username, "Mock username should be set to myuser")
        XCTAssertEqual("ffmockUserId", responseFromCompleteBlock!.authContext.userIdentityId, "Mock Pi userId should be set ffmockUserId")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_simulated_errorParsingUserIdData() {
        var env = PGMEnvironment(environmentFromType: .SimulatedEnv)
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: nil)
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeUserIdData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthUserIdError, andDescription: "mockError parsing userId")
                return response
            }
        }
        
        let mockDataProvider = mockAuthDataProvider()
        let mockSerializer = mockAuthConnectorSerializer()
        
        authConnector.setMockDataProvider(mockDataProvider)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(5, responseFromCompleteBlock!.error.code, "Error code should be .AuthenticationError")
        XCTAssertEqual("mockError parsing userId", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    //Staging env:
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_staging_errorInAuthNetworkCallAndNilData_error() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error in completionHandler network call"))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("Error in completionHandler network call", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_staging_errorInAuthNetworkCallAndData_error() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}" //will return some data
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error with data when completionHandler network call"))
            }
        }
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockSerializerError")
                return response
            }
        }
        
        let mockSerializer = mockAuthConnectorSerializer()
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be .AuthenitcationError")
        XCTAssertEqual("mockSerializerError", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_staging_errorInSerializer() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding), nil)
            }
        }
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockError")
                return response
            }
        }
        
        let mockSerializer = mockAuthConnectorSerializer()
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be .AuthenitcationError")
        XCTAssertEqual("mockError", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunAuthenticationRequestWithUsernamePasswordAndResponse_staging_success() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding), nil)
            }
        }
        
        class mockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                let authContext = PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 100000)
                response.authContext = authContext
                return response
            }
        }
        
        let mockSerializer = mockAuthConnectorSerializer()
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runAuthenticationRequestWithUsername("myuser", password: "mypassword",
            andResponse: PGMAuthResponse(), onComplete: onComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertEqual("mockToken", responseFromCompleteBlock!.authContext.accessToken, "Mock access token should be set to mockToken")
        XCTAssertEqual("mockRefreshToken", responseFromCompleteBlock!.authContext.refreshToken, "Mock refresh token should be set to mockRefreshToken")
        XCTAssertEqual(100000, responseFromCompleteBlock!.authContext.tokenExpiresIn, "Mock expires in should be set to 100000")
        XCTAssertEqual("myuser", responseFromCompleteBlock!.authContext.username, "Mock username should be set to myuser")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_staging_errorInNetworkCallNilData_error() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error in completionHandler network call"))
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("Error in completionHandler network call", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_staging_errorInNetworkCallAndData_error() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Error in completionHandler network call"))
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeUserIdData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockSerializerError")
                return response
                
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        let mockSerializer = MockAuthConnectorSerializer()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("mockSerializerError", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_staging_errorInSerializer() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding), nil)
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeUserIdData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthenticationError, andDescription: "mockError")
                return response

            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        let mockSerializer = MockAuthConnectorSerializer()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            println("...and error is: \(authResponse.error.userInfo?.values.first as String)")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be .CoreNetworkCallError")
        XCTAssertEqual("mockError", responseFromCompleteBlock!.error.userInfo?.values.first as String, "Wrong error msg")
    }
    
    func testRunUserIdRequestWithResponseOnComplete_staging_success() {
        var env = PGMEnvironment(environmentFromType: .StagingEnv)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        var authConnector = PGMAuthConnector(environment: env,andClientOptions: clientOptions)
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding), nil)
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeUserIdData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.authContext.userIdentityId = "ffmockUserId"
                return response
            }
        }
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        let mockSerializer = MockAuthConnectorSerializer()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var onComplete: AuthConnectorRequestComplete =  {(authResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = authResponse
        }
        
        authConnector.runUserIdRequestWithResponse(passedInResponse, onComplete: onComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertEqual("mockToken", responseFromCompleteBlock!.authContext.accessToken, "Mock access token should be set to mockToken")
        XCTAssertEqual("mockRefreshToken", responseFromCompleteBlock!.authContext.refreshToken, "Mock refresh token should be set to mockRefreshToken")
        XCTAssertEqual(100000, responseFromCompleteBlock!.authContext.tokenExpiresIn, "Mock expires in should be set to 100000")
        XCTAssertEqual("myuser", responseFromCompleteBlock!.authContext.username, "Mock username should be set to myuser")
        XCTAssertEqual("ffmockUserId", responseFromCompleteBlock!.authContext.userIdentityId, "Mock Pi userId should be set ffmockUserId")
    }
    
    // MARK: refresh token tests
    
    func testRunRefreshTokenWithResponseAuthContextOnComplete_emptyRefreshToken_error() {
        
        //refresh token is nil:
        var authContext = PGMAuthenticatedContext() //not setting refresh token in context
        
        var authConnector = PGMAuthConnector()
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var refreshOnComplete: AuthConnectorRequestComplete =  {(refreshAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = refreshAuthResponse
        }
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(13, responseFromCompleteBlock!.error.code, "Error must be of type PGMAuthMissingRefreshTokenError when refresh token is nil")
        
        //refresh token is an empty string:
        var authContext2 = PGMAuthenticatedContext(accessToken: nil, refreshToken: "", andExpirationInterval: 0)
        
        responseFromCompleteBlock = nil
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext2, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(13, responseFromCompleteBlock!.error.code, "Error must be of type PGMAuthMissingRefreshTokenError when refresh token is empty")
    }
    
    func testRunRefreshTokenWithResponseAuthContextOnComplete_missingEnv_error() {
        
        var authContext = PGMAuthenticatedContext(accessToken: "12345", refreshToken: "67890", andExpirationInterval: 10)
        
        var authConnector = PGMAuthConnector(environment: nil, andClientOptions: nil)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var refreshOnComplete: AuthConnectorRequestComplete =  {(refreshAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = refreshAuthResponse
        }
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be AuthenticationError")
        XCTAssertTrue((responseFromCompleteBlock!.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
    }
    
    func testRunRefreshTokenWithResponseAuthContextOnComplete_missingClientOptions_error() {
        
        var authContext = PGMAuthenticatedContext(accessToken: "12345", refreshToken: "67890", andExpirationInterval: 10)
        
        var authConnector = PGMAuthConnector(environment: PGMEnvironment(environmentFromType: .StagingEnv), andClientOptions: nil)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var refreshOnComplete: AuthConnectorRequestComplete =  {(refreshAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = refreshAuthResponse
        }
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(0, responseFromCompleteBlock!.error.code, "Error code should be AuthenticationError")
        XCTAssertTrue((responseFromCompleteBlock!.error.userInfo?.values.first as String).utf16Count > 0, "Error desc should be returned.")
    }
    
    func testRunRefreshTokenWithResponseAuthContextOnComplete_networkError_error() {
        
        var authContext = PGMAuthenticatedContext(accessToken: "12345", refreshToken: "67890", andExpirationInterval: 10)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "Mock error in network call"))
            }
        }
        
        var authConnector = PGMAuthConnector(environment: PGMEnvironment(environmentFromType: .StagingEnv), andClientOptions: clientOptions)
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var refreshOnComplete: AuthConnectorRequestComplete =  {(refreshAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = refreshAuthResponse
        }
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.authContext)
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error code should be PGMCoreNetworkCallError")
        XCTAssertEqual("Mock error in network call", responseFromCompleteBlock!.error.userInfo?.values.first as String)
    }
    
    func testRunRefreshTokenWithResponseAuthContextOnComplete_success() {
        
        var authContext = PGMAuthenticatedContext(accessToken: "12345", refreshToken: "67890", andExpirationInterval: 10)
        var clientOptions = PGMAuthOptions(clientId: "clientId", andClientSecret: "secret",
            andRedirectUrl: "http://redirect.com")
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding), nil)
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeAuthenticationData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                let authContext = PGMAuthenticatedContext(accessToken: "mockToken", refreshToken: "mockRefreshToken", andExpirationInterval: 100)
                response.authContext = authContext
                return response
            }
        }
        
        var authConnector = PGMAuthConnector(environment: PGMEnvironment(environmentFromType: .StagingEnv), andClientOptions: clientOptions)
        
        let mockCoreNetworkRequester = MockCoreNetworkRequester()
        let mockSerializer = MockAuthConnectorSerializer()
        authConnector.setCoreNetworkRequester(mockCoreNetworkRequester)
        authConnector.setConnectorSerializer(mockSerializer)
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var refreshOnComplete: AuthConnectorRequestComplete =  {(refreshAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = refreshAuthResponse
        }
        
        authConnector.runRefreshTokenWithResponse(nil, authContext: authContext, onComplete: refreshOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNotNil(responseFromCompleteBlock!.authContext)
        XCTAssertEqual("mockToken", responseFromCompleteBlock!.authContext.accessToken)
        XCTAssertEqual("mockRefreshToken", responseFromCompleteBlock!.authContext.refreshToken)
        XCTAssertEqual(100, responseFromCompleteBlock!.authContext.tokenExpiresIn)
    }
    
    // MARK: forgot username tests
    
    func testRunForgotUsernameForEmailWithResponseOnComplete_networkErrorWithNilData_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error"))
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotUsrOnComplete: AuthConnectorRequestComplete =  {(forgotUsrAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotUsrAuthResponse
        }
        
        authConnector.runForgotUsernameForEmail("a@b.cd", withResponse: PGMAuthResponse(), onComplete: forgotUsrOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error type must be PGMCoreNetworkCallError")
        XCTAssertEqual("mock error", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotUsernameForEmailWithResponseOnComplete_nilResponseInput_networkErrorWithNilData_error() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error"))
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotUsrOnComplete: AuthConnectorRequestComplete =  {(forgotUsrAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotUsrAuthResponse
        }
        
        authConnector.runForgotUsernameForEmail("a@b.cd", withResponse: nil, onComplete: forgotUsrOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error type must be PGMCoreNetworkCallError")
        XCTAssertEqual("mock error", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotUsernameForEmailWithResponseOnComplete_piErrorWithData_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error - non-200 status"))
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeForgotUsernameData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthEmailNotFound, andDescription: "mock error no email")
                return response
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        authConnector.setConnectorSerializer(MockAuthConnectorSerializer())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotUsrOnComplete: AuthConnectorRequestComplete =  {(forgotUsrAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotUsrAuthResponse
        }
        
        authConnector.runForgotUsernameForEmail("a@b.cd", withResponse: PGMAuthResponse(), onComplete: forgotUsrOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(17, responseFromCompleteBlock!.error.code, "Error type must be PGMAuthEmailNotFound")
        XCTAssertEqual("mock error no email", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotUsernameForEmailWithResponseOnComplete_success() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil) //200 response
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotUsrOnComplete: AuthConnectorRequestComplete =  {(forgotUsrAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotUsrAuthResponse
        }
        
        authConnector.runForgotUsernameForEmail("a@b.cd", withResponse: PGMAuthResponse(), onComplete: forgotUsrOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    // MARK: forgot username tests
    func testRunForgotPasswordForUsernameWithResponseOnComplete_networkErrorWithNilData_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error"))
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotPasswrdOnComplete: AuthConnectorRequestComplete =  {(forgotPasswrdAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotPasswrdAuthResponse
        }
        
        authConnector.runForgotPasswordForUsername("myUser", withResponse: PGMAuthResponse(), onComplete: forgotPasswrdOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error type must be PGMCoreNetworkCallError")
        XCTAssertEqual("mock error", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotPasswordForUsernameWithResponseOnComplete_nilResponseInput_networkErrorWithNilData_error() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                
                onComplete(nil, PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error"))
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotPasswrdOnComplete: AuthConnectorRequestComplete =  {(forgotPasswrdAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotPasswrdAuthResponse
        }
        
        authConnector.runForgotPasswordForUsername("myUser", withResponse: nil, onComplete: forgotPasswrdOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(4, responseFromCompleteBlock!.error.code, "Error type must be PGMCoreNetworkCallError")
        XCTAssertEqual("mock error", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotPasswordForUsernameWithResponseOnComplete_piErrorWithData_error() {
        
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),
                    PGMError.createErrorForErrorCode(.CoreNetworkCallError, andDescription: "mock error - non-200 status"))
            }
        }
        
        class MockAuthConnectorSerializer: PGMAuthConnectorSerializer {
            private override func deserializeForgotPasswordData(data: NSData!, forResponse response: PGMAuthResponse!) -> PGMAuthResponse! {
                response.error = PGMError.createErrorForErrorCode(.AuthUsernameNotFoundError, andDescription: "mock error no email")
                return response
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        authConnector.setConnectorSerializer(MockAuthConnectorSerializer())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotPasswrdOnComplete: AuthConnectorRequestComplete =  {(forgotPasswrdAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotPasswrdAuthResponse
        }
        
        authConnector.runForgotPasswordForUsername("myUser", withResponse: PGMAuthResponse(), onComplete: forgotPasswrdOnComplete)
        
        XCTAssertNotNil(responseFromCompleteBlock!.error)
        XCTAssertEqual(21, responseFromCompleteBlock!.error.code, "Error type must be PGMAuthUsernameNotFoundError")
        XCTAssertEqual("mock error no email", responseFromCompleteBlock!.error.userInfo?.values.first as String)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
    
    func testRunForgotPasswordForUsernameWithResponseOnComplete_success() {
        class MockCoreNetworkRequester: PGMCoreNetworkRequester {
            private override func performNetworkCallWithRequest(request: NSURLRequest!, andCompletionHandler onComplete: NetworkRequestComplete!) {
                var jsonString = "{\"key\":\"value\"}"
                onComplete(jsonString.dataUsingEncoding(NSUTF8StringEncoding),nil) //200 response
            }
        }
        
        authConnector.setCoreNetworkRequester(MockCoreNetworkRequester())
        
        var responseFromCompleteBlock: PGMAuthResponse? = nil
        var forgotPasswrdOnComplete: AuthConnectorRequestComplete =  {(forgotPasswrdAuthResponse) -> () in
            println("Running onComplete...")
            responseFromCompleteBlock = forgotPasswrdAuthResponse
        }
        
        authConnector.runForgotPasswordForUsername("myUser", withResponse: PGMAuthResponse(), onComplete: forgotPasswrdOnComplete)
        
        XCTAssertNil(responseFromCompleteBlock!.error)
        XCTAssertNil(responseFromCompleteBlock!.authContext)
    }
}
