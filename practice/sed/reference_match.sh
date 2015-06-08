#!/usr/bin/env sh

# Back-ref to the whole match
echo robin | gsed 's/robin/& & smith/g'
