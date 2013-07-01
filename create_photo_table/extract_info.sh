#!/bin/bash

delimiter=":"
type=$1

#Extract the large photo filenames:
awk '/[0-9_].JPG/ \
{ \
    sub(/<a href="photos\/[a-z_]*\//, ""); \
    sub(/">/, ""); \
    print $0; \
}' photo_html/photos-$type.html > photo_data/names_$type.txt

#Extract the small photo filenames:
awk '/[0-9_]small.JPG/ \
{ \
    sub(/<img id="photo" src="photos\/'$type'\//, ""); \
    sub(/" alt="photo">/, ""); \
    print $0; \
}' photo_html/photos-$type.html > photo_data/names_small_$type.txt

#Extract the photo locations
awk '/<h5>[a-zA-Z.,'\'' ]*<\/h5>/ \
{ \
    sub(/<h5>/, ""); \
    sub(/<\/h5>/, ""); \
    print $0; \
}' photo_html/photos-$type.html > photo_data/locations_$type.txt

#Extract the photo dates:
awk '/<h5>[0-9\/]/ \
{ \
    sub(/<h5>/, "");
    sub(/<\/h5>/, "");
    print $0; \
}' photo_html/photos-$type.html > photo_data/dates_$type.txt

pr -m -t -s$delimiter  photo_data/names_$type.txt photo_data/names_small_$type.txt photo_data/locations_$type.txt photo_data/dates_$type.txt > photo_data/$type.part.txt
awk '/20[0-9]/ \
{ \
sub(/2008/, "2008'$delimiter$type$delimiter'"); \
sub(/2009/, "2009'$delimiter$type$delimiter'"); \
sub(/2010/, "2010'$delimiter$type$delimiter'"); \
sub(/2011/, "2011'$delimiter$type$delimiter'"); \
print $0; }' photo_data/$type.part.txt > photo_data/$type.txt

exit 0




