//
//  PGMCoreNetworkRequester.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/11/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NetworkRequestComplete)(NSData *data, NSError *error);

@interface PGMCoreNetworkRequester : NSObject

-(void) performNetworkCallWithRequest:(NSURLRequest*)request
                 andCompletionHandler:(NetworkRequestComplete)onComplete;

-(void) handleResponse:(NSURLResponse*)response
              withData:(NSData*)data
                 error:(NSError*)error
            OnComplete:(NetworkRequestComplete)onComplete;

@end
