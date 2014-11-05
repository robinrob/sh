#!/usr/bin/env sh

source $SHLOG_PATH


STR=$1

# Use this command to generate a PEM public key:
# openssl rsa -in ~/.ssh/id_rsa -pubout > ~/.ssh/id_rsa.pub.pem

green "Encrypting '$STR' ..."
rm -f encrypted.txt && echo $STR | openssl rsautl -encrypt -pubin -inkey ~/.ssh/id_rsa.pub.pem > encrypted.txt
yellow `cat encrypted.txt`

green "Decrypting $STR: $(yellow) `cat encrypted.txt | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa`"
