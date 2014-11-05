#!/usr/bin/env sh

echo "String to Encrypt" | openssl rsautl -pubin -inkey id_rsa.pub -encrypt -pkcs | openssl enc -base64

