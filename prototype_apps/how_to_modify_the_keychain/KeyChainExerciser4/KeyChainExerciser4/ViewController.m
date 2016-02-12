//
//  ViewController.m
//  KeyChainExerciser4
//
//  Created by Seals, Morris D on 11/21/14.
//  Copyright (c) 2014 Seals, Morris D. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // For single sign on and single sign off amongst multiple apps using our default group defined in PGMConstants
    //
    //
    // 1. How to set a value to a key in the Keychain.
    NSString                *user1KeyString             = @"jane_doe";
    NSString                *user1ValueString           = @"secret-password";
    NSData                  *user1ValueData             = [user1ValueString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@" ");
    NSLog(@"Example:  1");
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Setting a value:  'secret-password' in the keychain for key:  'jane_doe'.");
    [PGMSecureKeychainStorage storeKeychainData:user1ValueData withIdentifier:user1KeyString];
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");

    // 2. How to get a value out of the Keychain.
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  2");
    NSLog(@"Getting the value:  'secret-password', for the key:  'jane_doe', out of the keychain.");
    NSData                  *responseData               = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:@"jane_doe"];
    NSString                *responseString             = [NSString stringWithUTF8String:[responseData bytes]];
    NSLog( @"It should return:  secret-password:  %@", responseString );
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    
    // 3. How to delete a value and key pair out of the Keychain.
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  3");
    NSLog(@"Example of how to delete a key pair out of the Keychain for key:  'jane_doe'.");
    [PGMSecureKeychainStorage  deleteKeychainDataWithIdentifier:@"jane_doe"];
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    
    // 4. Make sure it is truly deleted.  (This step is not required).
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  4");
    NSLog(@"Getting the value:  'secret-password', for the key:  'jane_doe', out of the keychain.");
    NSData                  *secondResponseData               = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:@"jane_doe"];
    NSString                *secondResponseString;
    if ( secondResponseData == nil ) {
        secondResponseString = nil;
    } else {
        secondResponseString = [NSString stringWithUTF8String:[secondResponseData bytes]];
    }
    NSLog( @"Since it has already been deleted, it should return null:  %@", secondResponseString );
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // For sign on and sign off amongst one or many apps using the integrator defined group.
    //
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // For single sign on and single sign off amongst multiple apps using our default group defined in PGMConstants
    //
    //
    // 5. How to set a value to a key in the Keychain.
    NSString                *user2KeyString             = @"bob_smith";
    NSString                *user2ValueString           = @"wow-password";
    NSData                  *user2ValueData             = [user2ValueString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@" ");
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  5");
    NSLog(@"Setting a value:  'wow-password' in the keychain for key:  'bob_smith' for group:  'wow-group'.");
    [PGMSecureKeychainStorage storeKeychainData:user2ValueData withIdentifier:user2KeyString forGroup:@"wow-group"];
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    
    // 6. How to get a value out of the Keychain with a integrator defined group.
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  6");
    NSLog(@"Getting the value:  'wow-password', for the key:  'bob_smith', out of the keychain for group 'wow-group'.");
    NSData                  *responseData2               = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:@"bob_smith" forGroup:@"wow-group"];
    NSString                *responseString2             = [NSString stringWithUTF8String:[responseData2 bytes]];
    NSLog( @"It should return:  wow-password:  %@", responseString2 );
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    
    // 7. How to delete a value out of the Keychain with a integrator defined group.
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  7");
    NSLog(@"Getting the value:  'wow-password', for the key:  'bob_smith', out of the keychain for group 'wow-group'.");
    NSLog(@"Example of how to delete a key pair out of the Keychain for key:  'bob_smith' forGroup:  'wow-group'.");
    [PGMSecureKeychainStorage  deleteKeychainDataWithIdentifier:@"bob_smith" forGroup:@"wow-group"];
    NSLog( @"It should return:  wow-password:  %@", responseString2 );
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    
    // 8. How to make sure a key using a group was truly deleted.
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@"Example:  8");
    NSLog(@"Getting the value:  'secret-password', for the key:  'jane_doe', out of the Keychain for group 'wow-group'.");
    NSData                  *thirdResponseData               = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:@"bob_smith" forGroup:@"wow-group"];
    NSString                *thirdResponseString;
    if ( thirdResponseString == nil ) {
        thirdResponseString = nil;
    } else {
        thirdResponseString = [NSString stringWithUTF8String:[thirdResponseData bytes]];
    }
    NSLog( @"Since it has already been deleted, it should return:  null:  %@", thirdResponseData );
    NSLog(@"----------------------------------------------------------------------------------------");
    NSLog(@" ");
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
