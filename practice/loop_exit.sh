#!/usr/bin/env sh

for i in 1 2 3 4 5 6 7 8 9 10
do
    echo $i
    [[ $i == 5 ]] && exit 1
done