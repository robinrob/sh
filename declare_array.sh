#!/bin/bash
#Declare array with 4 elements
ARRAY=('one' 'two' 'three')
#get number of elements in the array
ELEMENTS=${#ARRAY[@]}

#echo each element in array
#for loop
for ((i=0;i<$ELEMENTS;++i)); do
	echo ${ARRAY[${i}]}
done

#other type of for loop
for i in `seq 0 2`; do
	echo ${ARRAY[${i}]}
done
