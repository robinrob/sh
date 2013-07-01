#/bin/bash

data="photo_data"

./extract_info.sh camera
./extract_info.sh phone

cat $data/camera.txt $data/phone.txt > astronomy.txt
 
exit 0