//
//  EncryptionTests.m
//  EncryptionTests
//
//  Created by esri MacBook on 7/6/2560 BE.
//  Copyright © 2560 Piyapan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Encryptor.h"

@interface EncryptionTests : XCTestCase

@end

@implementation EncryptionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleText
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSString *key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    NSString *text = @"  Hello World  ";
    
    NSString *encryptedText = [Encryptor encryptedData:text WithHexKey:key];
    NSString *decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, text, @"failed.");
}

- (void)testSameKey
{
    NSString *key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    NSString *text = @"  Hello World  ";
    
    NSString *encryptedText = [Encryptor encryptedData:text WithHexKey:key];
    
    key = key.uppercaseString;
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, text, @"failed.");
}

- (void)testWrongKey
{
    NSString *key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    NSString *text = @"  Hello World  ";
    
    NSString *encryptedText = [Encryptor encryptedData:text WithHexKey:key];
    
    key = @"4e 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    
    NSString *decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, nil, @"failed.");
}

- (void) testDecryptOnly
{
    NSString * encryptedText = @"df78cedebfb70624bb663a2eb8ba828adf78cedebfb70624bb663a2eb8ba828a9B354CBA0AB6F7763A88F04D83A237462BE1B68F8D2CFCD4FCDC575BE51333B431A45E86D9B9B5D21DBD91C044DA118C783D98F89E28911463F957E2DA3188F1F4615F637B7F089F6DAEFA352EABAF1AC6731C6E67D0644E36E8D5AFACEF3DC7795E0909DFF84CF92E773A0268F9C2F01232F0AC7E1152F4E3802B09CAC5B0E421DDEC41F55A56001E1D37CBD9E2865567E1ABF5A2B2F160EAD80B147F0A1A9B";
    NSString * key = @"3c 36 38 36 cf 4e 16 66 66 69 a2 5d a2 80 a1 86 1b 81 bd ff f9 75 71 38 c3 a7 06 05 a4 b2 f2 ce";
    NSString * decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, @"สวัสดีชาวโลก || $ ¢ € Й ﯚ Å || 1234567890 || The quick brown fox jumps over the lazy dog.", @"failed.");
}

- (void) testUTF8Text
{
    NSString * text = @"สวัสดีชาวโลก $ ¢ € Й ﯚ Å";
    NSString * key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    
    NSString * encryptedText = [Encryptor encryptedData:text WithHexKey:key];
    NSString * decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, text, @"failed.");
}

- (void) testLongText
{
    NSString * text = @"สวัสดีชาวโลก $ ¢ € Й ﯚ Å || The quick brown fox jumps over the lazy dog. 1234567890! \n This is second line! \t this is tab!";
    NSString * key = @"4f 07 76 f2 72 0b c4 ce 31 e2 6e bb 19 26 f7 9f cc 38 fa f0 e3 68 b6 81 cb 09 d6 df f3 e5 eb 49";
    
    NSString * encryptedText = [Encryptor encryptedData:text WithHexKey:key];
    NSString * decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
    
    XCTAssertEqualObjects(decryptedText, text, @"failed.");
}

- (void) testInvalidKey
{
    NSString *key = @"44 50 07 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    NSString *text = @"  Hello World  ";
    
    @try
    {
        [Encryptor encryptedData:text WithHexKey:key];
        
        [NSException raise:@"Error" format:@"Exception thrown expected because because key is invalid"];
    }
    @catch(NSException* e)
    {
        NSString* excenptionName = [e name];
        NSString* exceptionMessage = [e reason];
        
        XCTAssertEqualObjects(exceptionMessage, @"key length is not 256 bit (64 hex characters)", @"failed");
        XCTAssertEqualObjects(excenptionName, @"EncryptionError", @"failed");
    }
    
    @try
    {
        NSString * encryptedText = @"249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352";
        [Encryptor decryptedData:encryptedText WithHexKey:key];
        
        [NSException raise:@"Error" format:@"Exception thrown expected because because key is invalid"];
    }
    @catch(NSException* e)
    {
        NSString* excenptionName = [e name];
        NSString* exceptionMessage = [e reason];
        
        XCTAssertEqualObjects(exceptionMessage, @"key length is not 256 bit (64 hex characters)", @"failed");
        XCTAssertEqualObjects(excenptionName, @"EncryptionError", @"failed");
    }
}

- (void) testZeroByteKey
{
    NSString * key = @"44 52 00 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
    NSString *text = @"  Hello World  ";
    
    @try
    {
        [Encryptor encryptedData:text WithHexKey:key];
        
        [NSException raise:@"Error" format:@"Exception thrown expected because because key has zero byte"];
    }
    @catch(NSException* e)
    {
        NSString* excenptionName = [e name];
        NSString* exceptionMessage = [e reason];
        
        XCTAssertEqualObjects(exceptionMessage, @"key cannot contain zero byte block", @"failed");
        XCTAssertEqualObjects(excenptionName, @"EncryptionError", @"failed");
    }
    
    @try
    {
        NSString * encryptedText = @"249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352";
        [Encryptor decryptedData:encryptedText WithHexKey:key];
        
        [NSException raise:@"Error" format:@"Exception thrown expected because because key has zero byte"];
    }
    @catch(NSException* e)
    {
        NSString* excenptionName = [e name];
        NSString* exceptionMessage = [e reason];
        
        XCTAssertEqualObjects(exceptionMessage, @"key cannot contain zero byte block", @"failed");
        XCTAssertEqualObjects(excenptionName, @"EncryptionError", @"failed");
    }
}

@end
