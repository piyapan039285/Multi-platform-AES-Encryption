//
//  Encryptor.m
//  DCAWarroom
//
//  Created by user1 on 6/29/2560 BE.
//  Copyright © 2560 Kittithad Seangthong. All rights reserved.
//

#import "Encryptor.h"

@implementation Encryptor

+ (NSString *) generateRandomHex:(int) byteLength
{
    int stringLength = byteLength*2;
    
    NSString *alphabet  = @"abcdef0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:stringLength];
    
    for (NSUInteger i = 0U; i < stringLength; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    NSString* hexStr = [NSString stringWithString:s];
    
    //prevent null block.
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"00" withString:@"11"];
    
    return hexStr;
}

+ (NSData *)dataFromHexString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = string.lowercaseString;
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:string.length/2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    NSUInteger length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
        {
            [NSException raise:@"EncryptionError" format:@"Invalid encryption hex data"];
        }
        
        byte_chars[0] = c;
        
        c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
        {
            [NSException raise:@"EncryptionError" format:@"Invalid encryption hex data"];
        }
        byte_chars[1] = c;
        
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

+ (NSString *)dataTohexString:(NSData *)data
{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

+ (void)fillDataArray:(char **)dataPtr length:(NSUInteger)length usingHexString:(NSString *)hexString
{
    NSData *data = [Encryptor dataFromHexString:hexString];
    NSAssert((data.length + 1) == length, @"The hex provided didn't decode to match length");
    
    *dataPtr = malloc(length * sizeof(char));
    bzero(*dataPtr, sizeof(*dataPtr));
    memcpy(*dataPtr, data.bytes, data.length);
}

+ (NSString *)encryptedData: (NSString*)plainText WithHexKey:(NSString*)hexKey
{
    [Encryptor checkKey:hexKey];
    
    //generate random IV (16 bytes)
    NSString* hexIV = [Encryptor generateRandomHex:16];
    
    //convert plainText to hex string.
    NSData * bytesData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString * hexStr = [Encryptor dataTohexString:bytesData];
    
    NSString* cipherHexStr = [Encryptor __encryptedData:hexStr WithHexKey:hexKey hexIV:hexIV];
    
    if(cipherHexStr != nil)
    {
        NSString* hmacHexKey = [Encryptor generateRandomHex:16];
        NSString* hmacHexStr = [Encryptor __computeHMACWithHexIV:hexIV cipherHexStr:cipherHexStr hexKey:hexKey hmacHexKey:hmacHexKey];

        NSMutableString *mutuableStr = [NSMutableString stringWithCapacity:([cipherHexStr length] + [hexIV length])];
        [mutuableStr appendString:hexIV];
        [mutuableStr appendString:hmacHexKey];
        [mutuableStr appendString:hmacHexStr];
        [mutuableStr appendString:cipherHexStr];
    
        NSString* encryptedHexStr = [NSString stringWithString:mutuableStr];
    
        return encryptedHexStr;
    }
    else
    {
        return nil;
    }
}

+ (NSString *)decryptedData: (NSString*)hexStr WithHexKey:(NSString*)hexKey
{
    [Encryptor checkKey:hexKey];
    NSString *plainText = nil;
    
    if(hexStr.length > 128)
    {
        NSString *hexIV = [hexStr substringToIndex:32];
        NSString *hmacHexKey = [hexStr substringWithRange:NSMakeRange(32, 32)];
        NSString *hmacHexStr = [hexStr substringWithRange:NSMakeRange(64, 64)];
        NSString *ciperHexStr = [hexStr substringFromIndex:128];
        
        NSString *computedHmacHexStr = [Encryptor __computeHMACWithHexIV:hexIV cipherHexStr:ciperHexStr hexKey:hexKey hmacHexKey:hmacHexKey];
        computedHmacHexStr = computedHmacHexStr.lowercaseString;
        
        hmacHexStr = hmacHexStr.lowercaseString;
        if([hmacHexStr isEqualToString:computedHmacHexStr])
        {
            NSString * decryptedStr = [Encryptor __decryptedData:ciperHexStr WithHexKey:hexKey hexIV:hexIV];
            
            NSData *bytesData = [Encryptor dataFromHexString:decryptedStr];
            plainText = [[NSString alloc] initWithData:bytesData encoding:NSUTF8StringEncoding];
        }
    }
    
    return plainText;
}

//private methods
+ (void) checkKey: (NSString *) hexString
{
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hexString = hexString.lowercaseString;
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([hexString length] != 64)
    {
        [NSException raise:@"EncryptionError" format:@"key length is not 256 bit (64 hex characters)"];
    }
    
    for(int i=0;i<[hexString length];i+=2)
    {
        if([hexString characterAtIndex:i] == '0' && [hexString characterAtIndex:i+1] == '0')
        {
            [NSException raise:@"EncryptionError" format:@"key cannot contain zero byte block"];
        }
    }
}

+ (NSString*) __computeHMACWithHexIV: (NSString *) hexIV cipherHexStr:(NSString*) cipherHexStr hexKey:(NSString*) hexKey hmacHexKey:(NSString*) hmacHexKey
{
    hexKey = [hexKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hexKey = hexKey.lowercaseString;
    hexKey = [hexKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    hmacHexKey = hmacHexKey.lowercaseString;
    
    NSMutableString *dataBuilder = [NSMutableString stringWithCapacity: hexIV.length + hexKey.length + cipherHexStr.length];
    [dataBuilder appendString:hexIV];
    [dataBuilder appendString:cipherHexStr];
    [dataBuilder appendString:hexKey];
    
    NSString* hexString = [NSString stringWithString:dataBuilder];
    hexString = hexString.lowercaseString;
    
    const char *cKey  = [hmacHexKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString* hmacHexStr = [Encryptor dataTohexString:HMAC];
    return hmacHexStr;
}

+ (NSString *)__encryptedData: (NSString*)hexStr WithHexKey:(NSString*)hexKey hexIV:(NSString *)hexIV
{
    //Encryption will use AES, key size 256bit (32 bytes), iv size 128 bit (16 bytes), CBC Mode, PKCS7 Padding.
    
    // Fetch key data and put into C string array padded with \0
    char *keyPtr;
    [Encryptor fillDataArray:&keyPtr length:kCCKeySizeAES256+1 usingHexString:hexKey];
    
    // Fetch iv data and put into C string array padded with \0
    char *ivPtr;
    [Encryptor fillDataArray:&ivPtr length:kCCKeySizeAES128+1 usingHexString:hexIV];
    
    NSData* data = [Encryptor dataFromHexString:hexStr];
    
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if(cryptStatus == kCCSuccess)
    {
        NSData* encryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        NSString* encryptedHexStr = [Encryptor dataTohexString:encryptedData];

        return encryptedHexStr;
    }
    else
    {
        free(buffer);
        return nil;
    }
}

+ (NSString *)__decryptedData:(NSString*)hexStr WithHexKey:(NSString*)hexKey hexIV:(NSString *)hexIV
{
    // Fetch key data and put into C string array padded with \0
    char *keyPtr;
    [Encryptor fillDataArray:&keyPtr length:kCCKeySizeAES256+1 usingHexString:hexKey];
    
    // Fetch iv data and put into C string array padded with \0
    char *ivPtr;
    [Encryptor fillDataArray:&ivPtr length:kCCKeySizeAES128+1 usingHexString:hexIV];
    
    NSData* data = [Encryptor dataFromHexString:hexStr];
    
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );

    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted );
    
    if( cryptStatus == kCCSuccess )
    {
        // The returned NSData takes ownership of the buffer and will free it on deallocation
        NSData* decryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString* decryptedHexStr = [Encryptor dataTohexString:decryptedData];

        return decryptedHexStr;
    }
    else
    {
        free(buffer);
        return nil;
    }
}
@end
