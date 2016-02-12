//
//  PGMCoreNetworkRequesterTests.swift
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/14/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

import UIKit
import XCTest
import GRIDMobileSDK

class PGMCoreNetworkRequesterTests: XCTestCase {

    var networkRequester: PGMCoreNetworkRequester? = nil
    override func setUp() {
        super.setUp()
        
        networkRequester = PGMCoreNetworkRequester()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHandleResponseWithDataErrorOnComplete_error() {
        var error = NSError(domain: "com.testdomain", code: 55, userInfo: nil)
        
        var dataFromCompletionBlock: NSData? = nil
        var errorFromCompletionBlock: NSError? = nil
        var onComplete: NetworkRequestComplete =  {(data, error) -> () in
            println("Running onComplete for testHandleResponse...")
            dataFromCompletionBlock = data
            errorFromCompletionBlock = error
            
            println("Error is \(error!.description)")
        }
        
        networkRequester!.handleResponse(nil, withData: nil, error: error, onComplete: onComplete)
        
        XCTAssertNotNil(errorFromCompletionBlock)
        XCTAssertNil(dataFromCompletionBlock, "No data for error scenario")
        XCTAssertEqual(4, errorFromCompletionBlock!.code, "Error should be of type CoreNetworkCallError")
        XCTAssertTrue((errorFromCompletionBlock?.userInfo?.values.first as String).utf16Count > 0, "Must have error user info string")
    }
    
    func testHandleResponseWithDataErrorOnComplete_notHttpResponse_error() {
        var urlResponse = NSURLResponse()
        
        var dataFromCompletionBlock: NSData? = nil
        var errorFromCompletionBlock: NSError? = nil
        var onComplete: NetworkRequestComplete =  {(data, error) -> () in
            println("Running onComplete for testHandleResponse...")
            dataFromCompletionBlock = data
            errorFromCompletionBlock = error
            
            println("Error is \(error!.description)")
        }
        
        networkRequester!.handleResponse(nil, withData: nil, error: nil, onComplete: onComplete)
        
        XCTAssertNotNil(errorFromCompletionBlock)
        XCTAssertNil(dataFromCompletionBlock, "No data for error scenario")
        XCTAssertEqual(4, errorFromCompletionBlock!.code, "Error should be of type CoreNetworkCallError")
        XCTAssertEqual("Response type is not NSHTTPURLResponse", (errorFromCompletionBlock?.userInfo?.values.first as String), "Must have error user info string")
    }
    
    func testHandleResponseWithDataErrorOnComplete_Non200Response_error() {
        var testUrl = NSURL()
        var httpUrlResponse = NSHTTPURLResponse(URL: testUrl, statusCode: 400, HTTPVersion: "1.1", headerFields: nil)
        var jsonString: String = "{\"status\": \"error\",\"message\": \"Bad request\",\"code\": \"400-User error\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var dataFromCompletionBlock: NSData? = nil
        var errorFromCompletionBlock: NSError? = nil
        var onComplete: NetworkRequestComplete =  {(data, error) -> () in
            println("Running onComplete for non200Response...")
            dataFromCompletionBlock = data
            errorFromCompletionBlock = error
            
            println("Error is \(error!.description)")
        }
        
        networkRequester!.handleResponse(httpUrlResponse, withData: data, error: nil, onComplete: onComplete)
        
        XCTAssertNotNil(errorFromCompletionBlock)
        XCTAssertNotNil(dataFromCompletionBlock, "There should be data for non-200 response")
        XCTAssertEqual(4, errorFromCompletionBlock!.code, "Error should be of type CoreNetworkCallError")
        XCTAssertEqual("Non-200 HTTP status code", (errorFromCompletionBlock?.userInfo?.values.first as String), "Must have error user info string")
    }
    
    func testHandleResponseWithDataErrorOnComplete_200Response_success() {
        var testUrl = NSURL()
        var httpUrlResponse = NSHTTPURLResponse(URL: testUrl, statusCode: 200, HTTPVersion: "1.1", headerFields: nil)
        var jsonString: String = "{\"status\": \"success\",\"message\": \"Great job!\",\"code\": \"200\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var dataFromCompletionBlock: NSData? = nil
        var errorFromCompletionBlock: NSError? = nil
        var onComplete: NetworkRequestComplete =  {(data, error) -> () in
            println("Running onComplete for 200 success...")
            dataFromCompletionBlock = data
            errorFromCompletionBlock = error
        }
        
        networkRequester!.handleResponse(httpUrlResponse, withData: data, error: nil, onComplete: onComplete)
        
        XCTAssertNil(errorFromCompletionBlock)
        XCTAssertNotNil(dataFromCompletionBlock, "There should be data for 200 response")
    }
    
    func testHandleResponseWithDataErrorOnComplete_202Response_success() {
        var testUrl = NSURL()
        var httpUrlResponse = NSHTTPURLResponse(URL: testUrl, statusCode: 202, HTTPVersion: "1.1", headerFields: nil)
        var jsonString: String = "{\"status\": \"success\",\"message\": \"Great job!\",\"code\": \"202\"}"
        var data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var dataFromCompletionBlock: NSData? = nil
        var errorFromCompletionBlock: NSError? = nil
        var onComplete: NetworkRequestComplete =  {(data, error) -> () in
            println("Running onComplete for 202 success...")
            dataFromCompletionBlock = data
            errorFromCompletionBlock = error
        }
        
        networkRequester!.handleResponse(httpUrlResponse, withData: data, error: nil, onComplete: onComplete)
        
        XCTAssertNil(errorFromCompletionBlock)
        XCTAssertNotNil(dataFromCompletionBlock, "There should be data for 200 response")
    }
}
