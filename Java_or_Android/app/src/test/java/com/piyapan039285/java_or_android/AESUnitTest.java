package com.piyapan039285.java_or_android;

import org.junit.Test;

import javax.crypto.Cipher;

import static org.junit.Assert.*;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class AESUnitTest 
{
    @Test
    public void checkAESRestrictedKeyLength() throws Exception
    {
        int length = Cipher.getMaxAllowedKeyLength("AES");

        if(length < 256)
            throw new Exception("You have to \"install unlimited strength policy files.\" first!. More info: https://stackoverflow.com/questions/6481627/java-security-illegal-key-size-or-default-parameters");
    }

    @Test
    public void SimpleText() throws Exception
    {
        String text = "  Hello World  ";
        String key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

        String encryptedText = Encryption.encryptData(text, key);

        String decryptedText = Encryption.decryptData(encryptedText, key);

        assertEquals(decryptedText, text);
    }

    @Test
    public void decryptOnly() throws Exception
    {
        String encryptedText = "249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352";
        String key = "3c 36 38 36 cf 4e 16 66 66 69 a2 5d a2 80 a1 86 1b 81 bd ff f9 75 71 38 c3 a7 06 05 a4 b2 f2 ce";
        String decryptedText = Encryption.decryptData(encryptedText, key);

        assertEquals(decryptedText, "สวัสดีชาวโลก || $ ¢ € Й ﯚ Å || 1234567890 || The quick brown fox jumps over the lazy dog.");
    }

    @Test
    public void UTF8Text() throws Exception
    {
        String text = "สวัสดีชาวโลก $ ¢ € Й ﯚ Å";
        String key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

        String encryptedText = Encryption.encryptData(text, key);

        String decryptedText = Encryption.decryptData(encryptedText, key);

        assertEquals(decryptedText, text);
    }

    @Test
    public void LongText() throws Exception
    {
        String text = "สวัสดีชาวโลก $ ¢ € Й ﯚ Å || The quick brown fox jumps over the lazy dog. 1234567890! \n This is second line! \t this is tab!";
        String key = "4f 07 76 f2 72 0b c4 ce 31 e2 6e bb 19 26 f7 9f cc 38 fa f0 e3 68 b6 81 cb 09 d6 df f3 e5 eb 49";

        String encryptedText = Encryption.encryptData(text, key);

        String decryptedText = Encryption.decryptData(encryptedText, key);

        assertEquals(decryptedText, text);
    }

    @Test
    public void invalidKey() throws Exception
    {
        String text = "  Hello World  ";
        String key = "44 52 d7 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

        try
        {
            String encryptedText = Encryption.encryptData(text, key);

            throw new Exception("Exception thrown expected because key length is invalid");
        }
        catch (Exception E)
        {
            assertEquals(E.getMessage(), "key length is not 256 bit (64 hex characters)");
        }

        try
        {
            String decryptedText = Encryption.decryptData("249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352", key);

            throw new Exception("Exception thrown expected because key length is invalid");
        }
        catch (Exception E)
        {
            assertEquals(E.getMessage(), "key length is not 256 bit (64 hex characters)");
        }
    }

    @Test
    public void zeroByteKey() throws Exception
    {
        String text = "  Hello World  ";
        String key = "44 00 d7 ee 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

        try
        {
            String encryptedText = Encryption.encryptData(text, key);

            throw new Exception("Exception thrown expected because key has zero byte");
        }
        catch (Exception E)
        {
            assertEquals(E.getMessage(), "key cannot contain zero byte block");
        }

        try
        {
            String decryptedText = Encryption.decryptData("249ec2837616f746f0055f3cc43adbddB403B528EBDF9AF29126BD70D85C904BF3F25748FB22898E1E837FE9D67133ED6DF2F70882CF2EF5060A1E87250AF92762479E4858159AADFC512052DA00630339663ED7DC359A9B02EC40B67E0E12F3E3CA6723D2E18CA1F239CDF0486F0B7D28C2A730C3DA4A0342A2D1C02D833839BDF6819610A2FBC34CFA0AB4C64A9352", key);

            throw new Exception("Exception thrown expected because key has zero byte");
        }
        catch (Exception E)
        {
            assertEquals(E.getMessage(), "key cannot contain zero byte block");
        }
    }
}