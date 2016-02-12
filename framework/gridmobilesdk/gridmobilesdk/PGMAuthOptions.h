//
//  PGMAuthOptions.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGMAuthOptions : NSObject

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectUrl;

-(instancetype) initWithClientId:(NSString*)clientId
                 andClientSecret:(NSString*)clientSecret
                  andRedirectUrl:(NSString*)redirectUrl;

@end
