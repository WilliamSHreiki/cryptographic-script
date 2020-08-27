#!/bin/bash

#bash Crypto.sh -e receiverpublic.key senderprivate.key test_lab2_1.txt x_file

#echo "test1"
#echo $1
if [[ $1 = "-e" ]]

then
#echo "test2"

mkdir -p encrypt

#step 1; generate symetric keys

openssl rand 16 | hexdump -e '16/1 "%02x" "\n"' > /tmp/iv

openssl rand 16 | hexdump -e '16/1 "%02x" "\n"' > /tmp/key

echo "Symmetric keys generated!"

#step 2; Encrypt the keys

openssl rsautl -encrypt -inkey $2 -pubin -in /tmp/iv -out encrypt/x_iv.txt

openssl rsautl -encrypt -inkey $2 -pubin -in /tmp/key -out encrypt/x_key.txt

echo "Symmetric keys encrypted!"

#step 3; Encrypt the message using Symmetric key

openssl aes-128-cbc -iv $(<"/tmp/iv") -K $(<'/tmp/key') -e -in $4 -out encrypt/$5

echo "file encrypted!"

#step 4; assign a signature

openssl dgst -sha256 -sign $3 -out encrypt/SignedFile $4

echo "encryption folder given signature!"

#step 5; zip the file

zip -r zipencrypt.zip encrypt

echo "encryption folder zipped!"

fi

#bash Crypto.sh -d receiverprivate.key senderpublic.key x_file decryptedmessage

if [[ $1 = "-d" ]]
then

unzip zipencrypt.zip

openssl rsautl -decrypt -inkey $2 -in encrypt/x_iv.txt -out decrypted_iv

openssl rsautl -decrypt -inkey $2 -in encrypt/x_key.txt -out decrypted_key

openssl aes-128-cbc -iv $(<"decrypted_iv") -K $(<"decrypted_key") -d -in encrypt/$4 -out $5.txt

openssl dgst -sha256 -verify $3 -signature encrypt/SignedFile $5.txt

echo "decrypted!"

fi

