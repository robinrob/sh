#!/usr/bin/env sh

source $SH_HOME/colors.sh

for file in `find . -name [a-zA-Z0-9]\* -depth 1 -type f`
do
	green "Moving $file to /tmp/"
	mv $file /tmp/
done