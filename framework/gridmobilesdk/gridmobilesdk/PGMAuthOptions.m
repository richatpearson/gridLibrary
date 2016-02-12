//
//  PGMAuthOptions.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthOptions.h"

@implementation PGMAuthOptions

-(instancetype) initWithClientId:(NSString*)clientId
                 andClientSecret:(NSString*)clientSecret
                  andRedirectUrl:(NSString*)redirectUrl {
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    self.redirectUrl = redirectUrl;
    
    return self;
}
@end
