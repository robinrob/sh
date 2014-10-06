#!/usr/bin/env sh

files=`gfind . -iregex '.*\(rb\|haml\)' -printf '%p\n'`
for file in $files
do
	echo "file: $file"
	gsed -i "s/\([a-z_]\+\):\{1\}\s\+\(\('\|"'"'"\)\?[-a-zA-Z0-9{}:@]\+\('\|"'"'"\)\?\)/:\1 => \2/g" $file
done