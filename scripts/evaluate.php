<?php 

$db = new mysqli('localhost', 'root', '1234', 'knowmin-mik');

$thresholdAdd = 0.6;
$thresholdReview = 0.3;

$totalCategories = $db->query('SELECT COUNT(DISTINCT category) AS count FROM categories_join')->fetch_object()->count;

$categories = array();

echo "Preparing ...\n";
$categoriesQuery = $db->query('SELECT DISTINCT category FROM categories_join');
while ($row = mysqli_fetch_row($categoriesQuery)) {
	$categories[] = $row[0];
}

echo "Processing results ...\n";
$evaluatedCategories = 1;
echo "Progress: 0.00%\r";

foreach ($categories as $category) {

	# processing evaluation_results
	$resourcesInCategoryQuery = $db->query("SELECT COUNT(DISTINCT subject) AS count FROM categories_join WHERE `category` = \"$category\"");
	$resourcesInCategory = $resourcesInCategoryQuery->fetch_object()->count;
	$predicateObjectPairsQuery = $db->query("SELECT DISTINCT predicate, object FROM categories_join WHERE `category` = \"$category\"");
	while ($row = mysqli_fetch_row($predicateObjectPairsQuery)) {
		$predicate = $row[0];
		$object = $row[1];
		$countQuery = $db->query("SELECT COUNT(*) AS count FROM categories_join WHERE `category` = \"$category\" AND `predicate` = \"$predicate\" AND `object` = \"$object\"");
		$count = $countQuery->fetch_object()->count;
		$probability = (int)$count / (int)$resourcesInCategory;
		$insertQuery = "INSERT INTO `evaluation_results` (category, predicate, object, probability) VALUES (\"$category\", \"$predicate\", \"$object\", $probability)";
		$db->query($insertQuery);
	}

	# processing suggestions
	$evaluationResultsQuery = $db->query("SELECT * FROM evaluation_results WHERE `category` = \"$category\"");
	while ($row = mysqli_fetch_row($evaluationResultsQuery)) {
		$predicate = $row[1];
		$object = $row[2];
		$probability = $row[3];
		$itemsWithoutPairQuery = $db->query("SELECT item FROM categories_join WHERE NOT `predicate` = \"$predicate\" AND NOT `object` = \"$object\"");
		if ($itemsWithoutPairQuery) {
			while ($row = mysqli_fetch_row($itemsWithoutPairQuery)) {
				$subject = $row[0];
				$status = 'D';
				if ($probability > $thresholdAdd) {
					$status = 'A';

				} elseif ($probability > $thresholdReview) {
					$status = 'R';
				}
				$insertQuery = "INSERT INTO `suggestions` (status, subject, predicate, object, probability) VALUES (\"$status\", \"$subject\", \"$predicate\", \"$object\", $probability)";
				$db->query($insertQuery);
			}
		}
	}

	$progress = $evaluatedCategories / $totalCategories;
	$progress = number_format($progress * 100, 2);
	echo "Progress: $progress%\r";
	$evaluatedCategories++;
}
