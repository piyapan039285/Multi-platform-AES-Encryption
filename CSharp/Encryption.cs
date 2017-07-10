using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace AES
{
    public class Encryption
    {
        public static string generateRandomHex(int byteLength)
        {
            int stringLength = byteLength * 2;

            string alphabet = "abcdef0123456789";
            string s = "";

            Random rnd = new Random();

            for (int i = 0; i < stringLength; i++)
            {
                int r = rnd.Next(0, alphabet.Length);

                s += alphabet[r];
            }

            //prevent NULL byte block.
            s = s.Replace("00", "11");

            return s;
        }

        private static byte[] dataFromHexString(string hexString)
        {
            hexString = hexString.Trim();
            hexString = hexString.Replace(" ", "");

            byte[] data = Enumerable.Range(0, hexString.Length / 2)
                                    .Select(x => Convert.ToByte(hexString.Substring(x * 2, 2), 16))
                                    .ToArray();

            return data;
        }

        private static string dataToHexString(byte[] data)
        {
            string hexString = String.Concat(Array.ConvertAll(data, x => x.ToString("X2")));

            return hexString;
        }

        public static string encryptData(string text, string hexKey)
        {
            checkKey(hexKey);

            //generate random IV (16 bytes)
            string hexIV = generateRandomHex(16);
            
            //convert plainText to hex string.
            byte[] bytesData = System.Text.Encoding.UTF8.GetBytes(text);
            string hexStr = dataToHexString(bytesData);

            string cipherHexStr = __encryptData(hexStr, hexKey, hexIV);

            string hmacHexKey = generateRandomHex(16);
            string hmacHexStr = Encryption.__computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

            string encryptedHexStr = hexIV + hmacHexKey + hmacHexStr + cipherHexStr;
            return encryptedHexStr;
        }

        public static string decryptData(string hexStr, string hexKey)
        {
            checkKey(hexKey);
            string plainText = null;

            if (hexStr.Length > 128)
            {
                string hexIV = hexStr.Substring(0, 32);
                string hmacHexKey = hexStr.Substring(32, 32);
                string hmacHexStr = hexStr.Substring(64, 64);
                string cipherHexStr = hexStr.Substring(128);

                string computedHmacHexStr = Encryption.__computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

                if (computedHmacHexStr.ToLower() == hmacHexStr.ToLower())
                {
                    string decryptedStr = __decryptData(cipherHexStr, hexKey, hexIV);

                    byte[] data = dataFromHexString(decryptedStr);
                    plainText = System.Text.Encoding.UTF8.GetString(data);
                }
            }

            return plainText;
        }

        private static void checkKey(string hexKey)
        {
            hexKey = hexKey.Trim();
            hexKey = hexKey.Replace(" ", "");
            hexKey = hexKey.ToLower();

            if(hexKey.Length != 64)
            {
                throw new Exception("key length is not 256 bit (64 hex characters)");
            }

            int i;
            for(i=0;i<hexKey.Length;i+=2)
            {
                if(hexKey[i] == '0' && hexKey[i+1] == '0')
                {
                    throw new Exception("key cannot contain zero byte block");
                }
            }
        }

        private static string __computeHMAC(string hexIV, string cipherHexStr, string hexKey, string hmacHexKey)
        {
            hexKey = hexKey.Trim();
            hexKey = hexKey.Replace(" ", "");
            hexKey = hexKey.ToLower();

            hmacHexKey = hmacHexKey.ToLower();

            string hexString = hexIV + cipherHexStr + hexKey;
            hexString = hexString.ToLower();

            byte[] data = System.Text.Encoding.UTF8.GetBytes(hexString);
            byte[] hmacKey = System.Text.Encoding.UTF8.GetBytes(hmacHexKey);

            HMACSHA256 hmac = new HMACSHA256(hmacKey);
            byte[] hashbytes = hmac.ComputeHash(data);
            string hashHexStr = Encryption.dataToHexString(hashbytes);

            return hashHexStr;
        }

        public static string __encryptData(string hexString, string hexKey, string hexIV)
        {
            byte[] data = dataFromHexString(hexString);
            byte[] key = dataFromHexString(hexKey);
            byte[] iv = dataFromHexString(hexIV);

            var aes = Aes.Create();
            aes.Mode = CipherMode.CBC;
            aes.Padding = PaddingMode.PKCS7;
            var encryptor = aes.CreateEncryptor(key, iv);
            
            MemoryStream memoryStream = new MemoryStream();
            CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write);
            cryptoStream.Write(data, 0, data.Length);
            cryptoStream.FlushFinalBlock();

            byte[] encryptData = memoryStream.ToArray();

            string encryptHexData = dataToHexString(encryptData);
            return encryptHexData;
        }

        private static string __decryptData(string hexString, string hexKey, string hexIV)
        {
            byte[] data = dataFromHexString(hexString);
            byte[] key = dataFromHexString(hexKey);
            byte[] iv = dataFromHexString(hexIV);
            
            var aes = Aes.Create();
            aes.Mode = CipherMode.CBC;
            aes.Padding = PaddingMode.PKCS7;
            var decryptor = aes.CreateDecryptor(key, iv);

            MemoryStream memoryStream = new MemoryStream();
            CryptoStream cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Write);
            cryptoStream.Write(data, 0, data.Length);
            cryptoStream.FlushFinalBlock();

            byte[] decryptData = memoryStream.ToArray();

            string decryptHexData = dataToHexString(decryptData);
            return decryptHexData;
        }
    }
}
