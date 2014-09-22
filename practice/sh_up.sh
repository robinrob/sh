#!/bin/sh

for file in `find . -regex '.*/[a-zA-Z0-9_-]*' -depth 1 -type f`
do
	mv $file $file.sh
done