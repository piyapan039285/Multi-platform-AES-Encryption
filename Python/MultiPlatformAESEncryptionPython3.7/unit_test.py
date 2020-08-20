import unittest
from encryption import encrypt_data, decrypt_data


class TestMethods(unittest.TestCase):
    def test_simple_text(self):
        text = "  Hello World  "
        key = "44 52 d7 16 87 b6 bc 2c 93 89 c3 34 9f dc 17 fb 3d fb ba 62 24 af fb 76 76 e1 33 79 26 cd d6 02"

        encrypted_text = encrypt_data(text, key)
        decrypted_text = decrypt_data(encrypted_text, key)

        self.assertEqual(text, decrypted_text)
    #
    # def test_upper(self):
    #     self.assertEqual('foo'.upper(), 'FxO')
    #
    # def test_isupper(self):
    #     self.assertTrue('FOO'.isupper())
    #     self.assertFalse('Foo'.isupper())
    #
    # def test_split(self):
    #     s = 'hello world'
    #     self.assertEqual(s.split(), ['hello', 'world'])
    #     # check that s.split fails when the separator is not a string
    #     with self.assertRaises(TypeError):
    #         s.split(2)


if __name__ == '__main__':
    unittest.main()