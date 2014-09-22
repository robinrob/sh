#!/bin/sh

SUBJECT=$1
if [ -z "$2" ]
then
    ADDRESS='robin.smith@cloudreach.co.uk'
fi
echo $1 | mail -s "REMINDER: $SUBJECT" $ADDRESS

