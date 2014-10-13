#!/bin/bash

ARG=$1
if [ -z "$ARG" ]
then
    echo "null mate!"
fi

if [ -n "$ARG" ]
then
    echo "not null mate!"
fi
