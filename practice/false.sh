#!/usr/bin/env sh

if [[ 1 ]]
then
	echo "true!"
fi

if [[ 0 ]]
then
	echo "false!"
fi

if [[ "" ]]
then
	echo "false!"
fi

if [[ !"" ]]
then
	echo "true!"
fi