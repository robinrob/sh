#!/bin/bash

data_dir="photo_data"
delimiter=":"
type=$1

#Extract the camera photo filenames:
awk '/<a href="astronomy\/camera\//' photo_html/astronomy.html \
| \
awk '/''/ \
{ \
    sub(/<a href="astronomy\/camera\//, ""); \
    sub(/">/, ""); \
    print $0; \
}' > $data_dir/names_camera.txt

#Extract the phone photo filenames:
awk '/<a href="astronomy\/phone\//' photo_html/astronomy.html \
| \
awk '/''/ \
{ \
    sub(/<a href="astronomy\/phone\//, ""); \
    sub(/">/, ""); \
    print $0; \
}' > $data_dir/names_phone.txt

cat $data_dir/names_camera.txt $data_dir/names_phone.txt > $data_dir/names.txt

#Extract the short camera photo filenames:
awk '/<img id="photo" src="astronomy\/camera\//' photo_html/astronomy.html \
| \
awk '/''/ \
{ \
    sub(/<img id="photo" src="astronomy\/camera\//, ""); \
    sub(/">/, ""); \
    print $0; \
}' > $data_dir/short_names_camera.txt

#Extract the short phone photo filenames:
awk '/<img id="photo" src="astronomy\/phone\//' photo_html/astronomy.html \
| \
awk '/''/ \
{ \
    sub(/<img id="photo" src="astronomy\/phone\//, ""); \
    sub(/">/, ""); \
    print $0; \
}' > $data_dir/short_names_phone.txt

cat $data_dir/short_names_camera.txt $data_dir/short_names_phone.txt > $data_dir/short_names.txt

#Extract the locations:
awk '/[a-zA-Z \-]<\/h5>/ \
{ \
    sub(/<h5>/, ""); \
    sub(/<\/h5>/, ""); \
    print $0; \
}' photo_html/astronomy.html > $data_dir/locations.txt

#Extract the dates:
awk '/[0-9\/]<\/h5>/ \
{ \
    sub(/<h5>/, ""); \
    sub(/<\/h5>/, ""); \
    print $0; \
}' photo_html/astronomy.html > $data_dir/dates.txt

pr -m -t -s$delimiter  $data_dir/names.txt $data_dir/short_names.txt $data_dir/locations.txt $data_dir/dates.txt > $data_dir/astronomy.part.txt

awk '/\/0000/ \
{ \
sub(/\/0000/, "\/0000'$delimiter'"); \
print $0; \
}' $data_dir/astronomy.part.txt \
| \
awk '\
{ \
    sub(/0:/, "0:phone:"); \
    print $0; \
}' > astronomy.txt

exit 0




