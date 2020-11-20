# Multi-platform-AES-Encryption
Ready-To-Use AES-256 bit encryption library which **supports across platforms**. For example, you can encrypt message using Java and decrypt it using Swift. [View Demo](https://firebasestorage.googleapis.com/v0/b/multi-platform-aes-encryption.appspot.com/o/demo.html?alt=media&token=051a8034-ff34-47ce-82f4-2e0f30880ecb)

Encryption method is AES with CBC mode (random IV in each encryption), PCKS7 padding (aka. PCKS5), and HMAC-256 authentication.

## Language Supported
* C# (.NET Framework 4.5)
* Java 8 (can be used with Android), Java 11
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
**Installation**
 1. If you use windows 7, 8 you need to install .NET Framework 4.5 from this [link](https://www.microsoft.com/en-us/download/details.aspx?id=30653)
 1. Create .NET Framework 4.5 Project in Visual Studio.
 1. copy `\CSharp\Encryption.cs` to your C# project.
 1. build project.

<br/>

**Example**
<br/>

See more example at file ```\CSharp\AESUnitTest\UnitTest1.cs```
```csharp
string text = "  Hello World  ";
string key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

string encryptedText = AES.Encryption.encryptData(text, key);
string decryptedText = AES.Encryption.decryptData(encryptedText, key);
```

## Java
**Installation**
 1. copy file to project
    * Java 8: `\Java_or_Android\app\src\main\java\com\piyapan039285\java_or_android\Encryption.java`
    * Java 11: `/Java11/src/main/java/com/piyapan039285/Encryption.java`
 1. build project.

**Example**
<br/>
See more example at this file
  * java 8: ```\Java_or_Android\app\src\test\java\com\piyapan039285\java_or_android\AESUnitTest.java```
  * Java 11: ```/Java11/src/test/java/com/piyapan039285/AESUnitTest.java```

```java
String text = "  Hello World  ";
String key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

String encryptedText = Encryption.encryptData(text, key);
String decryptedText = Encryption.decryptData(encryptedText, key);
```

Note: For Java 8, If you want to run unit test, you have to download "unlimited strength file" (link below). Then, install file to ${java.home}/jre/lib/security/. In Android Studio, you can find JDK path from ```Files -> Project Structure -> SDK Location.```
* unlimited strength file - Java 8 : http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html


## Objective C
**Installation**
 1. copy ```\ObjectiveC\ObjectiveC\Encryptor.m```, ```\ObjectiveC\ObjectiveC\Encryptor.h``` to your project.
 1. build project.

**Example**
<br/>
See more example at ```\ObjectiveC\EncryptionTests\EncryptionTests.m```

```objectivec
NSString *text = @"  Hello World  ";
NSString *key = @"44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

NSString *encryptedText = [Encryptor encryptedData:text WithHexKey:key];
NSString *decryptedText = [Encryptor decryptedData:encryptedText WithHexKey:key];
```

## Swift
**Installation**
 1. copy file to project
    * swift 3: ```Swift\Swift3.1\Swift3.1\Encryption.swift```
    * swift 4: ```Swift\Swift4\Encryption_Swift\Encryption.swift``` 
    * swift 5: ```Swift\Swift5\Encryption_Swift\Encryption.swift```
 1. add ```Security.framework``` library and add ```#import <CommonCrypto/CommonCryptor.h>```, ```#import <CommonCrypto/CommonHMAC.h>``` to the bridging header as shown in image below (More info : [here](https://stackoverflow.com/questions/37268368/swift-bridging-header-file-wont-work?answertab=votes#tab-top)) 

![](/Swift/images/bridging_header.png)
<br/>
<br/>
![](/Swift/images/security_framework.png)

<br/>

**Example**
<br/>

See more example at this file
  * Swift 3: ```Swift\Swift3.1\EncryptionTests\EncryptionTests.swift```
  * Swift 4: ```Swift\Swift4\EncryptionTests\EncryptionTests.swift```
  * Swift 5: ```Swift\Swift5\EncryptionTests\Encryption_SwiftTests.swift```

```swift
let text:String = "  Hello World  ";
let key:String = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

let encryptedText:String? = Encryption.encryptData(plainText: text, hexKey: key)
let decryptedText:String? = Encryption.decryptData(hexStr: encryptedText!, hexKey: key)
```

## NodeJS
**Installation**
 1. copy ```\NodeJS\encryption.js``` to your project.
 1. build project.

**Example**
<br/>

See more example at ```\NodeJS\unitTest.js```

```js
var encryptor = require("./encryption");

var text = "  Hello World  ";
var key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02";

var encryptedText = encryptor.encryptData(text, key);
var decryptedText = encryptor.decryptData(encryptedText, key);
```

## Python
**Installation**
 1. add `pycrypto==2.6.1` to requirements.txt file. Then, run `pip install -r requirements.txt`
 1. copy ```/Python/MultiPlatformAESEncryptionPython3.7/encryption.py``` to your project.

**Example**
<br/>
See more example at ```/Python/MultiPlatformAESEncryptionPython3.7/unit_test.py```

```python
from encryption import encrypt_data, decrypt_data

text = "  Hello World  "
key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02"

encrypted_text = encrypt_data(text, key)
decrypted_text = decrypt_data(encrypted_text, key)
```

## Javascript
**Installation**
 1. copy ```javascript\encryption.js```, ```javascript\forge.min.js``` to your project.
 1. add script section in your html file. 
 ```
  <script src="forge.min.js"></script>
  <script src="encryption.js"></script>
 ```

**Example**
<br/>
See more example at ```javascript\unitTest.html```

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
