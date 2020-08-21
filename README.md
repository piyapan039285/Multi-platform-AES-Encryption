# Multi-platform-AES-Encryption
Ready-To-Use AES-256 bit encryption library which **supports across platforms**. For example, you can encrypt message using Java and decrypt it using Swift. [View Demo](https://firebasestorage.googleapis.com/v0/b/multi-platform-aes-encryption.appspot.com/o/demo.html?alt=media&token=051a8034-ff34-47ce-82f4-2e0f30880ecb)

Encryption method is AES with CBC mode (random IV in each encryption), PCKS7 padding (aka. PCKS5), and HMAC-256 authentication.

## Language Supported
* C#
* Java (Android)
* Objective-C
* Swift 3, 4, 5
* NodeJS
* Python 3.7
* Javascript (Tested on Chrome 59, Firefox 54, IE 10-11)

## Input
* **plain_text** (string) : string MUST be able to be converted into UTF-8 encoding.
* **key** (string) : string in hexadecimal format (64 characters length). Space in string is allowed.

## Output
* **encrypted_string** (string) : string in hexadecimal format.

**Note** : ```decryption``` method will ouput ```null``` if you pass wrong key.

<br/>
<br/>

# Sample Usage
## C#
* Class : ```\CSharp\Encryption.cs```
* Unit Test : ```\CSharp\AESUnitTest\UnitTest1.cs```

<br/>

**Example**
<br/>

```csharp
string text = "  Hello World  ";
string key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

string encryptedText = AES.Encryption.encryptData(text, key);
string decryptedText = AES.Encryption.decryptData(encryptedText, key);
```

## Java, Android
* Class ```\Java_or_Android\app\src\main\java\com\piyapan039285\java_or_android\Encryption.java```
* Unit Test ```\Java_or_Android\app\src\test\java\com\piyapan039285\java_or_android\AESUnitTest.java```

**Important** : If you want to run unit test, you have to download "unlimited strength file" (link below). Then, install file to ${java.home}/jre/lib/security/. In Android Studio, you can find JDK path from ```Files -> Project Structure -> SDK Location.```
* unlimited strength file - Java 7 : http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html
* unlimited strength file - Java 8 : http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html

<br/>

**Example**
<br/>


```java
String text = "  Hello World  ";
String key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

String encryptedText = Encryption.encryptData(text, key);
String decryptedText = Encryption.decryptData(encryptedText, key);
```

## Objective C
* Class : ```\ObjectiveC\ObjectiveC\Encryptor.m```, ```\ObjectiveC\ObjectiveC\Encryptor.h```
* Unit Test : ```\ObjectiveC\EncryptionTests\EncryptionTests.m```

<br/>

**Example**
<br/>


```objectivec
NSString *text = @"  Hello World  ";
NSString *key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

NSString *encryptedText = [Encryptor encryptedData:text WithHexKey:key];
NSString *decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
```

## Swift
### Swift 3
* Class : ```Swift\Swift3.1\Swift3.1\Encryption.swift```
* Unit Test : ```Swift\Swift3.1\EncryptionTests\EncryptionTests.swift```

### Swift 4
* Class : ```Swift\Swift4\Encryption_Swift\Encryption.swift```
* Unit Test : ```Swift\Swift4\EncryptionTests\EncryptionTests.swift```

### Swift 5
* Class : ```Swift\Swift5\Encryption_Swift\Encryption.swift```
* Unit Test : ```Swift\Swift5\EncryptionTests\Encryption_SwiftTests.swift```

**Important** : To use in your project, you have to add ```Security.framework``` library and add ```#import <CommonCrypto/CommonCryptor.h>```, ```#import <CommonCrypto/CommonHMAC.h>``` to the bridging header as shown in image below (More info : [here](https://stackoverflow.com/questions/37268368/swift-bridging-header-file-wont-work?answertab=votes#tab-top)) 

![](/Swift/images/bridging_header.png)
<br/>
<br/>
![](/Swift/images/security_framework.png)

<br/>

**Example**
<br/>


```swift
let text:String = "  Hello World  ";
let key:String = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

let encryptedText:String? = Encryption.encryptData(plainText: text, hexKey: key)
let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText!, hexKey: key)
```

## NodeJS
* Module : ```\NodeJS\encryption.js```
* Unit Test : ```\NodeJS\unitTest.js```

<br/>

**Example**
<br/>


```js
var encryptor = require("./encryption");

var text = "  Hello World  ";
var key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

var encryptedText = encryptor.encryptData(text, key);
var decryptedText = encryptor.decryptData(encryptedText, key);
```

## Python
* Module : ```/Python/MultiPlatformAESEncryptionPython3.7/encryption.py```
* Unit Test : ```/Python/MultiPlatformAESEncryptionPython3.7/unit_test.py```

<br/>

**Example**
<br/>


```python
from encryption import encrypt_data, decrypt_data

text = "  Hello World  "
key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02"

encrypted_text = encrypt_data(text, key)
decrypted_text = decrypt_data(encrypted_text, key)
```

## Javascript
It is implemented based on [forge](https://github.com/digitalbazaar/forge) API.
* Javascript file : ```javascript\encryption.js```
* Unit Test :  ```javascript\unitTest.html```

<br/>

**Example**
<br/>


```xml
<html>
<head>
  <script src="forge.min.js"></script>
  <script src="encryption.js"></script>
  
  <script>
	var text = "  Hello World  ";
	var key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

	var encryptedText = encryptor.encryptData(text, key);
	var decryptedText = encryptor.decryptData(encryptedText, key);
  </script>  
</head>
<body>
</body>
</html>
```
