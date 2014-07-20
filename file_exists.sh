#!/usr/bin/env sh

if [ -f file_exists.sh ]
then
	echo "yes!"
else
	echo "no!"
fi

if ! [ -f file_exists.sh ]
then
	echo "yes!"
else
	echo "no!"
fi