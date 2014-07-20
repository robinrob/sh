#!/bin/bash

echo $1 | sed 's/\(.*\)\..*/\1/'

file=$(echo $1 | sed 's/\(.*\)\..*/\1/')
echo 'file: '$file
