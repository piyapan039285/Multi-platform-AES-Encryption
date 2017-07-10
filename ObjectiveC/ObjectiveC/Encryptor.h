//
//  Encryptor.h
//  DCAWarroom
//
//  Created by user1 on 6/29/2560 BE.
//  Copyright © 2560 Kittithad Seangthong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

@interface Encryptor : NSObject
+ (NSString *)dataTohexString:(NSData *)data;
+ (NSData *)dataFromHexString:(NSString *)string;
+ (NSString *)encryptedData: (NSString*)plainText WithHexKey:(NSString*)hexKey;
+ (NSString *)decryptedData: (NSString*)hexStr WithHexKey:(NSString*)hexKey;
@end
