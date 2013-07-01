#!/bin/bash
# bash trap command
trap bashtrap INT
# bash clear screen command
clear;
# bash trap function is executed when CTRL-C is pressed:
# bash prints message => Executing bash trap subrutine !
bashtrap()
{
    echo "CTRL+C Detected !...executing bash trap !"
}
# for loop from 1 to 10
for i in `seq 1 10`; do
    echo "$i seconds to exit." 
    sleep 1; #pauses 1 second between iterations
done
echo "Exit Bash Trap Example!!!" 