#!/bin/bash
STRING=$1

N_STRINGS=0
for i in `ls`;
do
	N_STRINGS=$[$N_STRINGS+1]
done

echo "N STRINGS: "$N_STRINGS