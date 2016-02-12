//
//  PGMAuthKeychainStorageManager.h
//  gridmobilesdk
//
//  Created by Richard Rosiak on 11/21/14.
//  Copyright (c) 2014 Richard Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMAuthenticatedContext.h"

@interface PGMAuthKeychainStorageManager : NSObject

-(BOOL) storeKeychainAuthenticatedContext:(PGMAuthenticatedContext*)context
                                    error:(NSError**)error;

-(PGMAuthenticatedContext*) retrieveAuthContextForIdentifier:(NSString*)identifier;

-(BOOL) deleteAuthContextForIdentifier:(NSString*)identifier;

@end
