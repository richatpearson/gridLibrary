//
//  PGMError.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/3/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMError.h"

NSString* const PGMErrorDomain = @"com.pearsoned.gridmobile.gridmobilesdk.ErrorDomain";

@implementation PGMError

+ (NSError*) createErrorForErrorCode:(PGMClientErrorCode)errorCode
                          andDescription:(NSString*)errorDescription
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:NSLocalizedString(errorDescription, nil)
                   forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:PGMErrorDomain code:errorCode userInfo:errorDetail];
}

@end
