//
//  Encryption.swift
//  Swift3.1
//
//  Created by esri MacBook on 7/6/2560 BE.
//  Copyright © 2560 Piyapan. All rights reserved.
//

import Foundation

class Encryption: NSObject
{
    enum EncryptionError: Error {
        case RuntimeError(String)
    }
    
    class func generateRandomHex(bytelength: Int) -> String
    {
        let stringLength : Int = bytelength * 2
        let letters : NSString = "abcdef0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< stringLength
        {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    class func dataFromHexString(hexString: String) throws -> Data
    {
        var hexString = hexString.replacingOccurrences(of: " ", with: "")
        hexString = hexString.lowercased();
        
        var data = Data(capacity: hexString.characters.count / 2)
        
        for char in hexString.unicodeScalars
        {
            let c = char.value;
            
            if !((c >= 97 && c <= 102) || (c >= 48 && c <= 57))
            {
                throw EncryptionError.RuntimeError("Invalid encryption hex data")
            }
        }
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{2}", options: .caseInsensitive)
        
        regex.enumerateMatches(in: hexString, range: NSMakeRange(0, hexString.utf16.count))
        { match, flags, stop in
            let byteString = (hexString as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        return data
    }
    
    class func dataToHexString(data: Data) -> String
    {
        let hexString:String = data.map { String(format: "%02x", $0) }.joined(separator: "")
        
        return hexString;
    }
    
    class func encryptData(plainText:String, hexKey:String) -> String?
    {
        //generate random IV (16 bytes)
        let hexIV:String = generateRandomHex(bytelength: 16);
        
        let data:Data = plainText.data(using: String.Encoding.utf8)!
        let hexStr:String = dataToHexString(data: data)
        
        let cipherHexStr = try! __encryptData(hexStr: hexStr, hexKey: hexKey, hexIV: hexIV)
        
        if (cipherHexStr != "")
        {
            //concat IV with cipherHexStr.
            let encryptedHexStr:String = hexIV + cipherHexStr
            
            return encryptedHexStr;
        }
        else
        {
            return nil;
        }
    }
    
    class func decryptData(hexStr:String, hexKey:String) -> String?
    {
        //get IV from first 16 bytes (16 bytes = 32 hex characters)
        let index32th = hexStr.index(hexStr.startIndex, offsetBy: 32);
        let hexIV:String = hexStr.substring(to: index32th)
        
        //get encryptedStr from 16th bytes to the end.
        let encryptedStr:String = hexStr.substring(from: index32th)
        
        let decryptedStr:String = try! __decryptData(hexStr: encryptedStr, hexKey: hexKey, hexIV: hexIV)
        let data:Data = try! dataFromHexString(hexString: decryptedStr)
        
        let plainText:String? = String.init(data: data, encoding: String.Encoding.utf8)
        
        return plainText
    }
    
    class func __encryptData(hexStr: String, hexKey:String, hexIV:String) throws -> String
    {
        let data:Data = try! dataFromHexString(hexString: hexStr);
        let key:Data = try! dataFromHexString(hexString: hexKey);
        let iv:Data = try! dataFromHexString(hexString: hexIV);
        
        if(key.count != 32)
        {
            throw EncryptionError.RuntimeError("key length is not 256 bit (64 hex characters)")
        }
        
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let keyLength = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                iv.withUnsafeBytes {ivBytes in
                    key.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, data.count,
                                cryptBytes, cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        var encryptHexString:String = "";
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            
            encryptHexString = dataToHexString(data: cryptData);
        }
        
        return encryptHexString;
    }
    
    class func __decryptData(hexStr: String, hexKey:String, hexIV:String) throws -> String
    {
        let data:Data = try! dataFromHexString(hexString: hexStr);
        let key:Data = try! dataFromHexString(hexString: hexKey);
        let iv:Data = try! dataFromHexString(hexString: hexIV);
        
        if(key.count != 32)
        {
            throw EncryptionError.RuntimeError("key length is not 256 bit (64 hex characters)")
        }
        
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let keyLength = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                iv.withUnsafeBytes {ivBytes in
                    key.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, data.count,
                                cryptBytes, cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        var decryptHexString:String = "";
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            
            decryptHexString = dataToHexString(data: cryptData);
        }
        
        return decryptHexString;
    }
}
