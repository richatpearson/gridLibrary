//
//  PGMSecureKeychainStorage.h
//  KeyChainExerciser3
//
//  Created by Seals, Morris D on 11/20/14.
//  Copyright (c) 2014 Seals, Morris D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PGMConstants.h"


@interface PGMSecureKeychainStorage : NSObject {
    
}


+(BOOL)storeKeychainData:(NSData *)value withIdentifier:(NSString *)key;
+(BOOL)storeKeychainData:(NSData *)value withIdentifier:(NSString *)key forGroup:(NSString *)group;


+(NSData *)retrieveKeychainDataWithIdentifier:(NSString *)key;
+(NSData *)retrieveKeychainDataWithIdentifier:(NSString *)key forGroup:(NSString *)group;


+(BOOL)deleteKeychainDataWithIdentifier:(NSString *)key;
+(BOOL)deleteKeychainDataWithIdentifier:(NSString *)key forGroup:(NSString *)group;


@end





