//
//  Encryption.swift
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
        
        var randomString:String = ""
        
        for _ in 0 ..< stringLength
        {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        //prevent null block.
        randomString = randomString.replacingOccurrences(of: "00", with: "11")
        
        return randomString
    }
    
    private class func dataFromHexString(hexString: String) throws -> Data
    {
        var hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: " ", with: "")
        hexString = hexString.lowercased();
        
        var data = Data(capacity: hexString.count / 2)
        
        for char in hexString.unicodeScalars
        {
            let c = char.value;
            
            if !((c >= 97 && c <= 102) || (c >= 48 && c <= 57))
            {
                throw EncryptionError.RuntimeError("Invalid encryption hex data")
            }
        }
        
        let regex = try NSRegularExpression(pattern: "[0-9a-f]{2}", options: .caseInsensitive)
        
        regex.enumerateMatches(in: hexString, range: NSMakeRange(0, hexString.utf16.count))
        { match, flags, stop in
            let byteString = (hexString as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        return data
    }
    
    private class func dataToHexString(data: Data) -> String
    {
        let hexString:String = data.map { String(format: "%02x", $0) }.joined(separator: "")
        
        return hexString;
    }
    
    class func encryptData(plainText:String, hexKey:String) throws -> String?
    {
        try checkKey(hexString: hexKey)
        
        //generate random IV (16 bytes)
        let hexIV:String = generateRandomHex(bytelength: 16);
        
        let data:Data = plainText.data(using: String.Encoding.utf8)!
        let hexStr:String = dataToHexString(data: data)
        
        let cipherHexStr = try __encryptData(hexStr: hexStr, hexKey: hexKey, hexIV: hexIV)
        
        if (cipherHexStr != "")
        {
            let hmacHexKey:String = generateRandomHex(bytelength: 16);
            let hmacHexStr:String = __computeHMAC(hexIV: hexIV, cipherHexStr: cipherHexStr, hexKey: hexKey, hmacHexKey: hmacHexKey)
            
            let encryptedHexStr:String = hexIV + hmacHexKey + hmacHexStr + cipherHexStr
            
            return encryptedHexStr;
        }
        else
        {
            return nil;
        }
    }
    
    class func decryptData(hexStr:String, hexKey:String) throws -> String?
    {
        try checkKey(hexString: hexKey)
        
        var plainText:String? = nil;
        
        if(hexStr.count > 128)
        {
            let index32th = hexStr.index(hexStr.startIndex, offsetBy: 32);
            let hexIV:String = String(hexStr[..<index32th])
            
            let index64th = hexStr.index(hexStr.startIndex, offsetBy:64);
            let hmacHexKey:String = String(hexStr[index32th..<index64th])
            
            let index128th = hexStr.index(hexStr.startIndex, offsetBy:128);
            let hmacHexStr:String = String(hexStr[index64th..<index128th])
            
            let cipherHexStr:String = String(hexStr[index128th...])
        
            let computedHmacHexStr:String = __computeHMAC(hexIV: hexIV, cipherHexStr: cipherHexStr, hexKey: hexKey, hmacHexKey: hmacHexKey)
            
            if(computedHmacHexStr.lowercased() == hmacHexStr.lowercased())
            {
                let decryptedStr:String = try __decryptData(hexStr: cipherHexStr, hexKey: hexKey, hexIV: hexIV)
                let data:Data = try dataFromHexString(hexString: decryptedStr)
                
                plainText = String.init(data: data, encoding: String.Encoding.utf8)
            }
        }
        
        return plainText
    }
    
    private class func checkKey(hexString: String) throws
    {
        var hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: " ", with: "")
        hexString = hexString.lowercased();
        
        if(hexString.count != 64)
        {
            throw EncryptionError.RuntimeError("key length is not 256 bit (64 hex characters)")
        }
        
        var i:Int = 0;
        while(i < hexString.count)
        {
            let indexI:String.Index = hexString.index(hexString.startIndex, offsetBy: i)
            let indexI1:String.Index = hexString.index(hexString.startIndex, offsetBy: i+1)
            
            if(hexString[indexI] == "0" && hexString[indexI1] == "0")
            {
                throw EncryptionError.RuntimeError("key cannot contain zero byte block")
            }
            
            i+=2;
        }
    }
    
    private class func __computeHMAC(hexIV:String, cipherHexStr:String, hexKey:String, hmacHexKey:String) -> String
    {
        var hexKey = hexKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexKey = hexKey.replacingOccurrences(of: " ", with: "")
        hexKey = hexKey.lowercased();
        
        let hmacHexKey = hmacHexKey.lowercased();
        
        var hexString:String = hexIV + cipherHexStr + hexKey;
        hexString = hexString.lowercased();
        
        let keyBytes = hmacHexKey.cString(using: String.Encoding.utf8)
        let keyLen = Int(hmacHexKey.lengthOfBytes(using: String.Encoding.utf8))
        let data = hexString.cString(using: String.Encoding.utf8)
        let dataLen = Int(hexString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, keyLen, data, dataLen, result);
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        let hmacHexStr = hash as String;
        
        result.deallocate()
        
        return hmacHexStr
    }
    
    private class func __encryptData(hexStr: String, hexKey:String, hexIV:String) throws -> String
    {
        let data:Data = try dataFromHexString(hexString: hexStr);
        let key:Data = try dataFromHexString(hexString: hexKey);
        let iv:Data = try dataFromHexString(hexString: hexIV);
        
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
    
    private class func __decryptData(hexStr: String, hexKey:String, hexIV:String) throws -> String
    {
        let data:Data = try dataFromHexString(hexString: hexStr);
        let key:Data = try dataFromHexString(hexString: hexKey);
        let iv:Data = try dataFromHexString(hexString: hexIV);
        
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
