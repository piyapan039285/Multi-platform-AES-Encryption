//
//  EncryptionTests.swift
//  EncryptionTests
//
//  Created by esri MacBook on 7/6/2560 BE.
//  Copyright © 2560 Piyapan. All rights reserved.
//

import XCTest
@testable import Swift3_1

class EncryptionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleText() {
        let text:String = "  Hello World  ";
        let key:String = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
        
        let encryptedText:String? = Encryption.encryptData(plainText: text, hexKey: key)
        let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText!, hexKey: key)
        
        XCTAssertEqual(decryptedText, text, "failed");
    }
    
    func testDecryptOnly()
    {
        let encryptedText:String = "249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352";
        let key:String = "3c 36 38 36 cf 4e 16 66 66 69 a2 5d a2 80 a1 86 1b 81 bd ff f9 75 71 38 c3 a7 06 05 a4 b2 f2 ce";
        
        let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText, hexKey: key)
        
        XCTAssertEqual(decryptedText, "สวัสดีชาวโลก || $ ¢ € Й ﯚ Å || 1234567890 || The quick brown fox jumps over the lazy dog.", "failed");
    }
    
    func testUTF8Text()
    {
        let text:String = "สวัสดีชาวโลก $ ¢ € Й ﯚ Å";
        let key:String = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";
        
        let encryptedText:String? = Encryption.encryptData(plainText: text, hexKey: key)
        let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText!, hexKey: key)
        
        XCTAssertEqual(decryptedText, text, "failed");
    }
    
    func testLongText()
    {
        let text:String = "สวัสดีชาวโลก $ ¢ € Й ﯚ Å || The quick brown fox jumps over the lazy dog. 1234567890! \n This is second line! \t this is tab!";
        let key:String = "4f 07 76 f2 72 0b c4 ce 31 e2 6e bb 19 26 f7 9f cc 38 fa f0 e3 68 b6 81 cb 09 d6 df f3 e5 eb 49";
        
        let encryptedText:String? = Encryption.encryptData(plainText: text, hexKey: key)
        let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText!, hexKey: key)
        
        XCTAssertEqual(decryptedText, text, "failed");
    }
    
}
