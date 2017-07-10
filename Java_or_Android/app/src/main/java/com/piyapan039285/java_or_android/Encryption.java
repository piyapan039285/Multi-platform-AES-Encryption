package com.piyapan039285.java_or_android;

import java.math.BigInteger;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by Piyapan on 07/02/2017.
 */

public class Encryption
{
    public static String generateRandomHex(int byteLength)
    {
        int stringLength = byteLength * 2;

        String alphabet = "abcdef0123456789";
        String s = "";

        Random rand = new Random();

        for (int i = 0; i < stringLength; i++)
        {
            int r = rand.nextInt(alphabet.length());
            s += alphabet.charAt(r);
        }

        //prevent null block.
        s = s.replaceAll("00", "11");

        return s;
    }

    private static String dataToHexString(byte[] data) {
        StringBuilder str = new StringBuilder();
        for(int i = 0; i < data.length; i++)
            str.append(String.format("%02x", data[i]));

        String hexString = str.toString();
        return hexString;
    }

    private static byte[] dataFromHexString(String hexString) throws Exception
    {
        hexString = hexString.trim();
        hexString = hexString.replaceAll("[ ]", "");
        hexString = hexString.toLowerCase();

        String validHexChar = "abcdef0123456789";

        int len = hexString.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2)
        {
            char c1 = hexString.charAt(i);
            char c2 = hexString.charAt(i+1);

            if(!validHexChar.contains(""+c1) || !validHexChar.contains((""+c2)))
            {
                throw new Exception("Invalid encryption hex data");
            }

            data[i / 2] = (byte) ((Character.digit(c1, 16) << 4) + Character.digit(c2, 16));
        }
        return data;
    }

    public static String encryptData(String text, String hexKey) throws Exception
    {
        checkKey(hexKey);

        //generate random IV (16 bytes)
        String hexIV = generateRandomHex(16);

        //convert plainText to hex string.
        byte[] bytesData = text.getBytes(Charset.forName("UTF-8"));
        String hexStr = dataToHexString(bytesData);

        String cipherHexStr = __encryptData(hexStr, hexKey, hexIV);

        String hmacHexKey = generateRandomHex(16);
        String hmacHexStr = Encryption.__computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

        String encryptedHexStr = hexIV + hmacHexKey + hmacHexStr + cipherHexStr;
        return encryptedHexStr;
    }

    public static String decryptData(String hexStr, String hexKey) throws Exception
    {
        checkKey(hexKey);

        String plainText = null;
        if (hexStr.length() > 128)
        {
            String hexIV = hexStr.substring(0, 32);
            String hmacHexKey = hexStr.substring(32, 64);
            String hmacHexStr = hexStr.substring(64, 128);
            String cipherHexStr = hexStr.substring(128);

            String computedHmacHexStr = Encryption.__computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

            if (computedHmacHexStr.equalsIgnoreCase(hmacHexStr))
            {
                String decryptedStr = __decryptData(cipherHexStr, hexKey, hexIV);

                byte[] data = dataFromHexString(decryptedStr);
                plainText = new String(data, Charset.forName("UTF-8"));
            }
        }

        return plainText;
    }

    private static void checkKey(String hexKey) throws Exception
    {
        hexKey = hexKey.trim();
        hexKey = hexKey.replaceAll("[ ]", "");
        hexKey = hexKey.toLowerCase();

        if(hexKey.length() != 64)
        {
            throw new Exception("key length is not 256 bit (64 hex characters)");
        }

        int i;
        for(i=0;i<hexKey.length();i+=2)
        {
            if(hexKey.charAt(i) == '0' && hexKey.charAt(i+1) == '0')
            {
                throw new Exception("key cannot contain zero byte block");
            }
        }
    }

    private static String __computeHMAC(String hexIV, String cipherHexStr, String hexKey, String hmacHexKey) throws Exception
    {
        hexKey = hexKey.trim();
        hexKey = hexKey.replaceAll("[ ]", "");
        hexKey = hexKey.toLowerCase();

        hmacHexKey = hmacHexKey.toLowerCase();

        String hexString = hexIV + cipherHexStr + hexKey;
        hexString = hexString.toLowerCase();

        byte[] data = hexString.getBytes(Charset.forName("UTF-8"));
        byte[] hmacKey = hmacHexKey.getBytes(Charset.forName("UTF-8"));

        Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
        SecretKeySpec secret_key = new SecretKeySpec(hmacKey, "HmacSHA256");
        sha256_HMAC.init(secret_key);

        byte[] hashbytes = sha256_HMAC.doFinal(data);
        String hashHexStr = Encryption.dataToHexString(hashbytes);

        return hashHexStr;
    }

    private static String __encryptData(String hexString, String hexKey, String hexIV) throws Exception
    {
        byte[] data = dataFromHexString(hexString);
        byte[] keyBytes = dataFromHexString(hexKey);
        byte[] iv = dataFromHexString(hexIV);

        SecretKeySpec key = new SecretKeySpec(keyBytes, "AES");

        //PKCS5Padding is PKCS #7 padding in java.
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key, new IvParameterSpec(iv));

        byte[] encryptData = cipher.doFinal(data);

        String encryptHexData = dataToHexString(encryptData);
        return encryptHexData;
    }

    private static String __decryptData(String hexString, String hexKey, String hexIV) throws Exception
    {
        byte[] data = dataFromHexString(hexString);
        byte[] keyBytes = dataFromHexString(hexKey);
        byte[] iv = dataFromHexString(hexIV);

        SecretKeySpec key = new SecretKeySpec(keyBytes, "AES");

        //PKCS5Padding is PKCS #7 padding in java.
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, key, new IvParameterSpec(iv));

        byte[] decryptData = cipher.doFinal(data);

        String decryptHexData = dataToHexString(decryptData);
        return decryptHexData;
    }
}
