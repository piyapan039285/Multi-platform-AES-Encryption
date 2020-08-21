import math
import random
import codecs
from Crypto.Cipher import AES
from Crypto.Hash import HMAC, SHA256


def generate_random_hex(byte_length: int) -> str:
    string_length = byte_length * 2
    alphabet = "abcdef0123456789"
    s = ""

    for i in range(string_length):
        r = int(math.floor(random.random() * len(alphabet)))
        s += alphabet[r]

    # prevent null block.
    s = s.replace("00", "11")
    return s


def _data_from_hex_string(hex_string: str) -> bytes:
    hex_string = hex_string.strip().replace(' ', '').lower()
    alphabet = "abcdef0123456789"

    for ch in hex_string:
        if ch not in alphabet:
            raise Exception('Invalid encryption hex data')

    data_bytes = codecs.decode(hex_string, 'hex')
    return data_bytes


def data_to_hex_string(data_bytes: bytes) -> str:
    hex_string = codecs.encode(data_bytes, 'hex').decode()
    return hex_string


def encrypt_data(plain_text: str, hex_key: str) -> str:
    _check_key(hex_key)

    # generate random IV (16 bytes)
    hex_iv = generate_random_hex(16)

    # convert plainText to hex string.
    bytes_data = plain_text.encode('utf-8')
    hex_str = data_to_hex_string(bytes_data)

    cipher_hex_str = _encrypt_data(hex_str, hex_key, hex_iv)

    hmac_hex_key = generate_random_hex(16)
    hmac_hex_str = _compute_HMAC(hex_iv, cipher_hex_str, hex_key, hmac_hex_key)

    encrypted_hex_str = hex_iv + hmac_hex_key + hmac_hex_str + cipher_hex_str
    return encrypted_hex_str


def decrypt_data(hex_str: str, hex_key: str) -> str:
    _check_key(hex_key)

    plain_text = None
    if len(hex_str) > 128:
        hex_iv = hex_str[:32]
        hmac_hex_key = hex_str[32:64]
        hmac_hex_str = hex_str[64:128]
        cipher_hex_str = hex_str[128:]

        computed_hmac_hex_str = _compute_HMAC(hex_iv, cipher_hex_str, hex_key, hmac_hex_key)
        if computed_hmac_hex_str.lower() == hmac_hex_str.lower():
            decrypted_str = _decrypt_data(cipher_hex_str, hex_key, hex_iv)
            data = _data_from_hex_string(decrypted_str)
            plain_text = data.decode('utf-8')

    return plain_text


def _compute_HMAC(hex_iv: str, cipher_hex: str, hex_key: str, hmac_hex_key: str):
    hex_key = hex_key.strip().replace(' ', '').lower()
    hmac_hex_key = hmac_hex_key.lower()

    hex_str = hex_iv + cipher_hex + hex_key
    hex_str = hex_str.lower()

    data = hex_str.encode('utf-8')
    hmac_key = hmac_hex_key.encode('utf-8')

    hmac = HMAC.new(hmac_key, digestmod=SHA256)
    hmac.update(data)
    hash_bytes = hmac.digest()

    hash_hex_str = data_to_hex_string(hash_bytes)
    return hash_hex_str


def _check_key(hex_key: str):
    hex_key = hex_key.strip().replace(' ', '').lower()

    if len(hex_key) != 64:
        raise Exception("key length is not 256 bit (64 hex characters)")

    key_len = len(hex_key)
    i = 0
    while i < key_len:
        if hex_key[i] == '0' and hex_key[i+1] == '0':
            raise Exception("key cannot contain zero byte block")

        i += 2


def _encrypt_data(hex_string: str, hex_key: str, hex_iv: str) -> str:
    data = _data_from_hex_string(hex_string)
    key = _data_from_hex_string(hex_key)
    iv = _data_from_hex_string(hex_iv)

    # PyCrypto does not have PKCS7 Padding alforithm, I have to implement on my own.
    #
    # Note: if plain_text length is multiple of 16,
    #        then a sequence of value chr(BS) in length 16 will be appended to the origin data
    data = data + (chr(16 - len(data) % 16) * (16 - len(data) % 16)).encode('utf-8')

    cipher = AES.new(key, AES.MODE_CBC, iv)
    encrypted_data = cipher.encrypt(data)
    encrypted_hex_data = data_to_hex_string(encrypted_data)
    return encrypted_hex_data


def _decrypt_data(hex_string: str, hex_key: str, hex_iv: str) -> str:
    data = _data_from_hex_string(hex_string)
    key = _data_from_hex_string(hex_key)
    iv = _data_from_hex_string(hex_iv)

    cipher = AES.new(key, AES.MODE_CBC, iv)
    decrypted_data = cipher.decrypt(data)

    # PyCrypto does not have PKCS7 Padding alforithm, I have
    #   to implement un-pad on my own.
    decrypted_data = decrypted_data[:-ord(decrypted_data[len(decrypted_data) - 1:])]

    decrypted_hex_data = data_to_hex_string(decrypted_data)
    return decrypted_hex_data

