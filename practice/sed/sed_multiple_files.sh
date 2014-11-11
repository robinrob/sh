#!/usr/bin/env sh

source $SHLOG_PATH


# Run on multiple files
rm -f file1.txt file2.txt
echo "Hello" > file1.txt
echo "Hello" > file2.txt

green $(cat file1.txt)
green $(cat file2.txt)

cyan "You've really just got to do it in a loop:"

files=$(find . -regex '.*/file[0-9].txt' | xargs)

for i in $files
do
  gsed -i 's/Hello/World!/g' $i
done


yellow $(cat file1.txt)
yellow $(cat file1.txt)
