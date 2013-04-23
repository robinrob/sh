#!/bin/bash -eu

CC_RED=$(echo -e "\033[0;31m")
CC_YELLOW=$(echo -e "\033[0;33m")
CC_END=$(echo -e "\033[0m")

red()
{
	echo -e ${CC_RED}$1${CC_END}
}

yellow()
{
	echo -e ${CC_YELLOW}$1${CC_END}
}

print_details()
{
	for detail in "$1"
	do
		IN=$detail
		set -- "$IN" 
		IFS=":"; declare -a Array=($*) 
		yellow "${Array[0]}"
		red "${Array[1]}"
	done
}

test "robin:smith\nsmith:robin"