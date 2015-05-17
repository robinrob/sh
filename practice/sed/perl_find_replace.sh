#!/usr/bin/env sh

# -p flag applies the entire Perl program to each line of the file
# -e flag means that the Perl program follows
# -i flag can be used as with `sed` to write back to the file
perl -p -e 's/andrew/programming/g' name.txt
