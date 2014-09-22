#!/bin/bash

if [ -z "$1" ] && [ -z "$2" ]
	then
	echo "Both null mate."
elif [ -z "$1" ] || [ -z "$2" ]
	then
	echo "One argument is null."
else
	echo "Neither argument is null!"
fi
