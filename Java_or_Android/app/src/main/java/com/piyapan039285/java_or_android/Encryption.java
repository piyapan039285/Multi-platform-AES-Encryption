package com.piyapan039285.java_or_android;

import java.math.BigInteger;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;
import java.util.Random;

import javax.crypto.Cipher;
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

        return s;
    }

    private static String dataToHexString(byte[] data) {
        StringBuilder str = new StringBuilder();
        for(int i = 0; i < data.length; i++)
            str.append(String.format("%02x", data[i]));

        String hexString = str.toString();
        return hexString;
    }

    private static byte[] dataFromHexString(String hexString)
    {
        hexString = hexString.trim();
        hexString = hexString.replaceAll("[ ]", "");

        int len = hexString.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hexString.charAt(i), 16) << 4) + Character.digit(hexString.charAt(i+1), 16));
        }
        return data;
    }

    public static String encryptData(String text, String hexKey) throws GeneralSecurityException
    {
        //generate random IV (16 bytes)
        String hexIV = generateRandomHex(16);

        //convert plainText to hex string.
        byte[] bytesData = text.getBytes(Charset.forName("UTF-8"));
        String hexStr = dataToHexString(bytesData);

        String cipherHexStr = __encryptData(hexStr, hexKey, hexIV);

        //concat IV with cipherHexStr.
        String encryptedHexStr = hexIV + cipherHexStr;
        return encryptedHexStr;
    }

    public static String decryptData(String hexStr, String hexKey) throws GeneralSecurityException
    {
        String hexIV = hexStr.substring(0, 32);
        String encryptedStr = hexStr.substring(32);

        String decryptedStr = __decryptData(encryptedStr, hexKey, hexIV);

        byte[] data = dataFromHexString(decryptedStr);
        String plainText = new String(data, Charset.forName("UTF-8"));

        return plainText;
    }

    private static String __encryptData(String hexString, String hexKey, String hexIV) throws GeneralSecurityException
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

    private static String __decryptData(String hexString, String hexKey, String hexIV) throws GeneralSecurityException
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
