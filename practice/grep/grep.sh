#!/bin/bash

#Finds phone numbers which match the pattern [0-9] any
#amount of times. Option -o outputs only the matching
#string and -h removes file index names from the output.
grep -o -h [0-9]* numbers.txt numbers2.txt > out.txt

exit 0