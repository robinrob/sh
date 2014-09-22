#!/bin/bash

ARG_MSG="Invalid input.\nUsage: "$0" <old string> <new string>"
[[ $1 && $2 ]] || { echo -e $ARG_MSG >&2; exit 1; }

OLD_STRING=$1
NEW_STRING=$2

TMP_SUFFIX='.tmp'

for i in `find src -name '*meta.xml'`; do
	mv $i ${i}${TMP_SUFFIX}
	cat ${i}${TMP_SUFFIX} | sed 's/'${OLD_STRING}'/'${NEW_STRING}'/g' > ${i}
	rm -f ${i}${TMP_SUFFIX}
done