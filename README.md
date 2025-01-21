# cloudcrypt
Encrypt files for cloud storage

* Encrypts files symmetrically using a generated password.<br>
* The password is in turn encrypted with a private key and stored in a separate file.<br>
* Optionally, invoking -s will also store the password symmetrically encrypted. This can be useful when storing files long term.<br>
* Private keyid used for encrypting the password should be kept in cleartext in file ./keyid.

### Options:
  * -h, --help        Show this help message and exit.<br>
  * -d, --decrypted   Decrypted files path.<br>
  * -e, --encrypted   Encrypted files path.<br>
  * -s, --add-symmetric   Add symmetrically encrypte pass file.<br>

### Encrypt example
./encrypt.sh -d ./source -e ./target -s

### Decrypt example
./decrypt.sh -e ./source -d ./target



