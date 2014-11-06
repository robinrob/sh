#!/usr/bin/env sh

source $SHCOLORS_PATH

cyan "File exists"
if [ -f file_exists.sh ]
then
	echo "yes!"
else
	echo "no!"
fi



cyan "File does not exist"
if ! [ -f file_exists.sh ]
then
	echo "yes!"
else
	echo "no!"
fi



cyan "Both files exist"
if [ -f file_exists.sh -a -f file_exists.sh ]
then
	echo "yes!"
else
	echo "no!"
fi

