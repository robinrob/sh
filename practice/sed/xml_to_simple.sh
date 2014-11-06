#!/usr/bin/env sh

source $SHLOG_PATH


cat example.xml | grep 'key=' | gsed 's/.*key=\"\(.\+\)\"\svalue=\"\(.\+\)\".*./\1=\2/g'
