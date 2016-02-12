//
//  PGMCoreNetworkRequester.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/11/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMCoreNetworkRequester.h"
#import "PGMError.h"

@implementation PGMCoreNetworkRequester

-(void) performNetworkCallWithRequest:(NSURLRequest*)request
                 andCompletionHandler:(NetworkRequestComplete)onComplete {
    if (!request) {
        NSError *noRequestError = [PGMError createErrorForErrorCode:PGMAuthenticationError andDescription:@"No request for network call"];
        onComplete(nil, noRequestError);
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *sessionDataTask =
        [session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                              [self handleResponse:response withData:data error:error OnComplete:onComplete];
                          }];
    
    [sessionDataTask resume];
}

-(void) handleResponse:(NSURLResponse*)response
              withData:(NSData*)data
                 error:(NSError*)error
            OnComplete:(NetworkRequestComplete)onComplete {
    if (error) {
        NSLog(@"Networking error: %@", error.description);
        onComplete(nil, [PGMError createErrorForErrorCode:PGMCoreNetworkCallError andDescription:@"Error executing NSURL session task"]);
    }
    else {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
            NSInteger httpStatusCode = [httpURLResponse statusCode];
            NSLog(@"[HTTP statusCode is] %ld", (long)httpStatusCode);
            if (httpStatusCode >= 200 && httpStatusCode < 300) { //200-level success
                NSLog(@"Executing onComplete in completion of network requester.");
                onComplete(data, nil);
            }
            else {
                onComplete(data, [PGMError createErrorForErrorCode:PGMCoreNetworkCallError andDescription:@"Non-200 HTTP status code"]);
            }
        }
        else {
            onComplete(nil, [PGMError createErrorForErrorCode:PGMCoreNetworkCallError andDescription:@"Response type is not NSHTTPURLResponse"]);
        }
    }
}

@end
