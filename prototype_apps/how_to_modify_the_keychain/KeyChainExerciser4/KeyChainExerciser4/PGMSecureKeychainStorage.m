//
//  PGMSecureKeychainStorage.m
//  KeyChainExerciser3
//
//  Created by Seals, Morris D on 11/20/14.
//  Copyright (c) 2014 Seals, Morris D. All rights reserved.
//

#import "PGMSecureKeychainStorage.h"



@interface PGMSecureKeychainStorage (PrivateMethods)

+(NSMutableDictionary *)getKeyChainDictionary:(NSString *)key forGroup:(NSString *)group;

@end




@implementation PGMSecureKeychainStorage




+(BOOL)storeKeychainData:(NSData *)value withIdentifier:(NSString *)key {
    
    return  [self storeKeychainData:value withIdentifier:key forGroup:nil];
}

+(BOOL)storeKeychainData:(NSData *)value withIdentifier:(NSString *)key forGroup:(NSString *)group {
    
    BOOL    successBOOL = FALSE;
    
    if (key == nil) {
        return successBOOL;
    }
    
    NSMutableDictionary *queryNSMutableDictionary = [self getKeyChainDictionary:key forGroup:group];
    
    // See if the keychain already has this key or not.
    OSStatus keychainQueryResultCodeOSStatus = SecItemCopyMatching((__bridge CFDictionaryRef)queryNSMutableDictionary, NULL);
    if (        keychainQueryResultCodeOSStatus == errSecItemNotFound ) {
        // The item can not be found in the Keychain.  We must add it.
        [queryNSMutableDictionary setObject:value forKey:(__bridge id)kSecValueData];
        keychainQueryResultCodeOSStatus = SecItemAdd((__bridge CFDictionaryRef)queryNSMutableDictionary, NULL);
        if ( keychainQueryResultCodeOSStatus == errSecSuccess ) {
            // No Error
            successBOOL = TRUE;
            NSLog(@"PGMSecureKeychainStorage setValue success adding new key value to the Keychain." );
        } else {
            // Error
            successBOOL = FALSE;
            NSLog(@"PGMSecureKeychainStorage setValue failure adding new key value to the Keychain." );
        }
    } else if ( keychainQueryResultCodeOSStatus == errSecSuccess) {
        // No error.  So that means the item already exists in the Keychain.  We must update it.
        NSDictionary *updateNSDictionary = [NSDictionary dictionaryWithObject:value forKey:(__bridge id)kSecValueData];
        keychainQueryResultCodeOSStatus = SecItemUpdate((__bridge CFDictionaryRef)queryNSMutableDictionary, (__bridge CFDictionaryRef)updateNSDictionary);
        if ( keychainQueryResultCodeOSStatus == errSecSuccess ) {
            // No Error
            successBOOL = TRUE;
            NSLog(@"PGMSecureKeychainStorage setValue success adding to existing key value to the Keychain." );
        } else {
            // Error
            successBOOL = FALSE;
            NSLog(@"PGMSecureKeychainStorage setValue failure adding to existing key value to the Keychain." );
        }
    } else {
        // We got some other error.
        NSLog(@"PGMSecureKeychainStorage setValue failure adding to existing key value to the Keychain.  Unknown error." );
        
    }
    
    return  successBOOL;
}




+(NSData *)retrieveKeychainDataWithIdentifier:(NSString *)key {

    return [self retrieveKeychainDataWithIdentifier:key forGroup:nil];
}

+(NSData *)retrieveKeychainDataWithIdentifier:(NSString *)key forGroup:(NSString *)group {
    
    NSData  *value;
    
    // Build up the generic Keychain NSMutableDictionary we will need to retrieve to extract our data.
    NSMutableDictionary *queryNSMutableDictionary = [self getKeyChainDictionary:key forGroup:group];
    
    // Just get the first result
    [queryNSMutableDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Get NSData instead of a NSDictionary of attributes
    [queryNSMutableDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    
    // Get the value for the key from the Keychain as NSData and convert it to a NSString.
    CFDataRef resultCFDataRef = nil;
    
    // OSStatus is going to get us the result code (error or success) of the Keychain query.
    OSStatus  keychainQueryResultCodeOSStatus = SecItemCopyMatching((__bridge CFDictionaryRef)queryNSMutableDictionary, (CFTypeRef *)&resultCFDataRef);
    
    if ( keychainQueryResultCodeOSStatus == noErr ) {
        value = (__bridge_transfer NSData *)resultCFDataRef;
    } else {
        value = nil;
    }
    
    return value;
}




+(BOOL)deleteKeychainDataWithIdentifier:(NSString *)key {

    return [self deleteKeychainDataWithIdentifier:key forGroup:nil];
}

+(BOOL)deleteKeychainDataWithIdentifier:(NSString *)key forGroup:(NSString *)group {
    BOOL    succeededBOOL = FALSE;
    
    NSMutableDictionary *queryNSMutableDictionary = [self getKeyChainDictionary:key forGroup:group];
    
    OSStatus keychainQueryResultCodeOSStatus = SecItemDelete( (__bridge CFDictionaryRef)queryNSMutableDictionary );
    
    if (keychainQueryResultCodeOSStatus == errSecSuccess) {
        
        // Means we got no error, and that the item existed.
        succeededBOOL = TRUE;
    } else if   (keychainQueryResultCodeOSStatus == errSecItemNotFound) {
        
        // Means that it did not exist as a key.  This is OK, since it may have already been deleted.
        succeededBOOL = TRUE;
    } else {
        
        // Something went wrong.
        succeededBOOL = FALSE;
    }
    
    NSLog(@"PGMSecureKeychainStorage deleteDataWithKey succeededBOOL returning:  %@.", succeededBOOL ? @"TRUE" : @"FALSE" );
    
    return  succeededBOOL;
}




// This is a private function.
// This functions builds up a NSMutableDictionary with all the attributes we will need to securely set and get
// data into and out of the Keychain.  These were useful-
// https://developer.apple.com/library/IOs/samplecode/GenericKeychain/Introduction/Intro.html
// http://b2cloud.com.au/tutorial/using-the-keychain-to-store-passwords-on-ios/
//
+(NSMutableDictionary *)getKeyChainDictionary:(NSString *)key forGroup:(NSString *)group {
    
    // All values except the key NSString will be derived from constants.
    
    // Build a Dictionary to describe what we want out of the keychain.
    NSMutableDictionary *queryNSMutableDictionary = [NSMutableDictionary dictionary];
    
    
    // Set the type of this query to Generic Password.
    [queryNSMutableDictionary   setObject:(__bridge id)kSecClassGenericPassword         forKey:(__bridge id)kSecClass];
    
    
    // Key
    // Set the items identifier key, to distinguish itself between other generic Keychain items.
    // This could be something like a username or email address.
    [queryNSMutableDictionary   setObject:key                                           forKey:(__bridge id)kSecAttrAccount];
    
    // Value
    // Leave this commented!  It is here to show us where it will fit in this data structure, when we call:  setValue: forKey:.
    // Set the items value (for its key) to some fake/placeholder NSData.
    //NSData *placeHolderNSData = [@"placeholder_data" dataUsingEncoding:NSUTF8StringEncoding];
    //[queryNSMutableDictionary   setObject:placeHolderNSData                           forKey:(__bridge id)kSecValueData];
    
    
    // Other attributes about this Keychain entry.
    
    // Set the items label of how we want it displayed in the Keychain.
    [queryNSMutableDictionary   setObject:PGMStorageLabel                               forKey:(__bridge id)kSecAttrLabel];
    
    // Set the items service name we are providing.
    [queryNSMutableDictionary   setObject:PGMServiceName                                forKey:(__bridge id)kSecAttrService];
    
    // Set the items ability to access data in the Keychain to when the device is unlocked.
    [queryNSMutableDictionary   setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id)kSecAttrAccessible];
    
    
    // This code tells us if we are on a simulator or device.
    // Here we need to set the access group, but only on a real device, not the simulator.
    // These comments largely from-  https://developer.apple.com/library/IOs/samplecode/GenericKeychain/Introduction/Intro.html
    // Which is some older, but very well documented, keychain code from Apple last updated back in 2010.
    if ( [ [UIDevice currentDevice].model  rangeOfString:@"Simulator" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        // We are on a simulator.
        
        //
        // Ignore the access group if running on the iPhone simulator.
        //
        // Apps that are built for the simulator aren't signed, so there's no keychain access group
        // for the simulator to check. This means that all apps can see all keychain items when run
        // on the simulator.
        //
        // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
        // simulator will return -25243 (errSecNoAccessForItem).
        //
        // Will cause all keychains calls to fail in simulator.
        
    } else {
        
        // We are on a real device.
        
        // The keychain access group attribute determines if this item can be shared
        // amongst multiple apps whose code signing entitlements contain the same keychain access group.
        
        if ( group == nil ) {
            [queryNSMutableDictionary  setObject:PGMInterAppAccessGroup     forKey:(__bridge id)kSecAttrAccessGroup];
        } else {
            [queryNSMutableDictionary  setObject:group                      forKey:(__bridge id)kSecAttrAccessGroup];
        }
        
    }
    
    return queryNSMutableDictionary;
}










@end







