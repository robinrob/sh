#!/bin/bash

data="photo_data"
delimiter=":"
type=$1
echo "type: "$type

#Extract the dates:
awk '/<a href="astronomy\/phone\//' astronomy.html \
| \
awk '/'$type'/ \
{ \
    sub(/<a href="astronomy\/phone\//, ""); \
    sub(/">/, ""); \
    print $0; \
}'