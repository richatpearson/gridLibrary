//
//  PGMSecureKeychainConstants.m
//  KeyChainExerciser3
//
//  Created by Seals, Morris D on 11/20/14.
//  Copyright (c) 2014 Seals, Morris D. All rights reserved.
//

#import "PGMConstants.h"





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Constants for PGMSecureKeychainStorage

// This constant is an access group which will allow multiple apps to set and get values from the Keychain
// for this access group.  This is how we will use it.
NSString * const PGMInterAppAccessGroup             = @"Grid_Mobile_Platform_Inter_App_Access_Group_1";

// This constant is a helper label that we will use to store values in the Keychain.
NSString * const PGMStorageLabel                    = @"Grid_Mobile_Platform_Label";

// This constant defines the service we will be providing
NSString * const PGMServiceName                     = @"Grid_Mobile_Platform_Authentication_Service";

//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






@implementation PGMSecureKeychainConstants

@end
