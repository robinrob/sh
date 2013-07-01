<?php
/* Create a MySQL table for photos using data
 * from a file.
 */
include 'functions.php';

if (tableExists("photos")) {
	deleteTable("photos");
}

createTable('photos', 'image VARCHAR(16), small_image VARCHAR(16),
			date VARCHAR(16), location VARCHAR(32), type VARCHAR(16)');

$types[] = "animals";
$types[] = "beaches_oceans";
$types[] = "cities";
$types[] = "mountains_valleys";
$types[] = "sunrises";
$types[] = "sunsets";
$types[] = "trees_plants";

for ($i = 0; $i < 7; ++$i) {
	$names_file = fopen("photo_data/names_$types[$i].txt", "r");
	$small_names_file = fopen("photo_data/names_small_$types[$i].txt", "r");
	$locations_file = fopen("photo_data/locations_$types[$i].txt", "r");
	$dates_file = fopen("photo_data/dates_$types[$i].txt", "r");
	
	while ($name = fgets($names_file)) {
		$small_name = fgets($small_names_file);
		$location = addslashes(fgets($locations_file));
		echo "location: $location" . "<br />";
		$date = fgets($dates_file);
		queryMysql("INSERT INTO photos VALUES('$name', '$small_name', '$date', '$location', '$types[$i]')");
	}
}

?>