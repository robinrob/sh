#/bin/bash

data="photo_data"

./extract_info.sh animals
./extract_info.sh beaches_oceans
./extract_info.sh cities
./extract_info.sh mountains_valleys
./extract_info.sh sunrises
./extract_info.sh sunsets
./extract_info.sh trees_plants

cat $data/animals.txt $data/beaches_oceans.txt $data/cities.txt \
$data/mountains_valleys.txt $data/sunrises.txt $data/sunsets.txt \
$data/trees_plants.txt > photos.txt
 
exit 0