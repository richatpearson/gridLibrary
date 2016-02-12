//
//  PGMAuthKeychainStorageManager.m
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/21/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import "PGMAuthKeychainStorageManager.h"
#import "PGMSecureKeychainStorage.h"
#import "PGMError.h"

@implementation PGMAuthKeychainStorageManager

-(BOOL) storeKeychainAuthenticatedContext:(PGMAuthenticatedContext*)context
                                    error:(NSError**)error {

    if ( !context && error != nil ) {
        *error = [PGMError createErrorForErrorCode:PGMAuthMissingContextError andDescription:@""];
        return NO;
    }
    
    NSData *authContextData = [NSKeyedArchiver archivedDataWithRootObject:context];
    
    return [PGMSecureKeychainStorage storeKeychainData:authContextData
                                        withIdentifier:context.userIdentityId];
}

-(PGMAuthenticatedContext*) retrieveAuthContextForIdentifier:(NSString*)identifier {
    
    NSData *contextData = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:identifier];
    return (PGMAuthenticatedContext*)[NSKeyedUnarchiver unarchiveObjectWithData:contextData];
}

-(BOOL) deleteAuthContextForIdentifier:(NSString*)identifier {
    return [PGMSecureKeychainStorage deleteKeychainDataWithIdentifier:identifier];
}

@end
