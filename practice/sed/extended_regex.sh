#!/usr/bin/env sh

# + is not recognised as meta-character unless -r option i used
echo "123 abc" | gsed -r 's/[0-9]+/& &/'

# escaping the + with blackslash does the same thing
echo "123 abc" | gsed 's/[0-9]\+/& &/'

# The same thing applies to all extended-regex meta-characters
echo "robin smith" | gsed -r 's/([a-z]+) ([a-z]+)/\2 \1/'

echo "robin smith" | gsed 's/\([a-z]\+\) \([a-z]\+\)/\2 \1/'
