#!/usr/bin/env sh

# -i flag can be used as with `sed` to write back to the file
perl -p -e 's/andrew/programming/g' name.txt
