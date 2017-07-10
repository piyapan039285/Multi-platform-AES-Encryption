var encryptor = {
    generateRandomHex: function(byteLength)
    {
        var stringLength = byteLength * 2;

        var alphabet = "abcdef0123456789";
        var s = "";

        for (var i = 0; i < stringLength; i++)
        {
            var r = Math.floor(Math.random()*alphabet.length);

            s += alphabet[r];
        }

        //prevent null block.
        s = s.replace(new RegExp("00", 'g'), "11");

        return s;
    },

    '_dataFromHexString': function (hexString)
    {
        hexString = hexString.trim();
        hexString = hexString.replace(new RegExp(' ', 'g'), '');
        hexString = hexString.toLowerCase();

        var i;
        for(i=0;i<hexString.length;i++)
        {
            if("abcdef0123456789".indexOf(hexString[i]) == -1)
            {
                throw new Error('Invalid encryption hex data');
            }
        }

        var bytes = forge.util.hexToBytes(hexString);
        return bytes;
    },

    '_dataToHexString': function(bytes)
    {
        var hex = forge.util.bytesToHex(bytes);

        return hex;
    },

    '_checkKey': function(hexKey)
    {
        hexKey = hexKey.trim();
        hexKey = hexKey.replace(new RegExp(' ', 'g'), '');
        hexKey = hexKey.toLowerCase();

        if(hexKey.length != 64)
        {
            throw new Error("key length is not 256 bit (64 hex characters)");
        }

        var i;
        for(i=0;i<hexKey.length;i+=2)
        {
            if(hexKey[i] == '0' && hexKey[i+1] == '0')
            {
                throw new Error("key cannot contain zero byte block");
            }
        }
    },

    'encryptData': function(plainText, hexKey)
    {
        this._checkKey(hexKey);

        var hexIV = this.generateRandomHex(16);
        var hexString = this._dataToHexString(forge.util.encodeUtf8(plainText));

        var cipherHexStr = this._encryptData(hexString, hexKey, hexIV);

        var hmacHexKey = this.generateRandomHex(16);
        var hmacHexStr = this._computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

        var encryptData = hexIV + hmacHexKey + hmacHexStr + cipherHexStr;
        return encryptData;
    },

    'decryptData': function(hexStr, hexKey)
    {
        this._checkKey(hexKey);
        var plainText = null;

        if (hexStr.length > 128)
        {
            var hexIV = hexStr.substr(0, 32);
            var hmacHexKey = hexStr.substr(32, 32);
            var hmacHexStr = hexStr.substr(64, 64);
            var cipherHexStr = hexStr.substr(128);

            var computedHmacHexStr = this._computeHMAC(hexIV, cipherHexStr, hexKey, hmacHexKey);

            if (computedHmacHexStr.toLowerCase() == hmacHexStr.toLowerCase())
            {
                var decryptedStr = this._decryptData(cipherHexStr, hexKey, hexIV);
                plainText = forge.util.decodeUtf8(forge.util.hexToBytes(decryptedStr));
            }
        }

        return plainText;
    },

    '_computeHMAC': function(hexIV, cipherHexStr, hexKey, hmacHexKey)
    {
        hexKey = hexKey.trim();
        hexKey = hexKey.replace(new RegExp(' ', 'g'), '');
        hexKey = hexKey.toLowerCase();

        hmacHexKey = hmacHexKey.toLowerCase();

        var hexString = hexIV + cipherHexStr + hexKey;
        hexString = hexString.toLowerCase();

        var hmac = forge.hmac.create();
        hmac.start('sha256', hmacHexKey);
        hmac.update(hexString);

        var hashHexStr = hmac.digest().toHex();
        return hashHexStr;
    },

    '_encryptData': function(hexString, hexKey, hexIV)
    {
        var data = this._dataFromHexString(hexString);
        var key = this._dataFromHexString(hexKey);
        var iv = this._dataFromHexString(hexIV);

        //Note: CBC mode use PKCS#7 padding as default
        var cipher = forge.cipher.createCipher('AES-CBC', key);
        cipher.start({'iv': iv});
        cipher.update(forge.util.createBuffer(data));
        cipher.finish();

        var encryptedData = cipher.output.toHex();
        
        return encryptedData;
    },

    '_decryptData': function(hexString, hexKey, hexIV)
    {
        var data = this._dataFromHexString(hexString);
        var key = this._dataFromHexString(hexKey);
        var iv = this._dataFromHexString(hexIV);

        //Note: CBC mode use PKCS#7 padding as default
        var decipher = forge.cipher.createDecipher('AES-CBC', key);
        decipher.start({'iv': iv});
        decipher.update(forge.util.createBuffer(data));
        var result = decipher.finish(); // check 'result' for true/false

        var decryptedData = decipher.output.toHex();

        return decryptedData;
    }
};