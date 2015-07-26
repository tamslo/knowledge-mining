<?php

include_once "./Helper.php";

class Evaluator {

	CONST THRESHOLD_ADD = 0.6;
	CONST THRESHOLD_REVIEW = 0.3;

	private $helper;

	public function __construct() {
		$this->helper = new Helper();
	}

	public function execute() {
		$db = $this->helper->getDB();

		echo "Preparing ...\n";
		$totalCategories = $db->query( 'SELECT COUNT(DISTINCT category) AS count FROM join_categories_statements' )->fetch_object()->count;

		$categories = array();
		$categoriesQuery = $db->query( 'SELECT DISTINCT category FROM join_categories_statements' );
		while ( $row = mysqli_fetch_row( $categoriesQuery ) ) {
			$categories[] = $row[0];
		}

		echo "Processing results ...\n";
		$evaluatedCategories = 1;

		$done = False;

		foreach ( $categories as $category ) {

			$interimResults = $this->getInterimResults( $db, $category );

			$this->createSuggestions( $db, $interimResults, $category );

			if ( !$done ) {
				$done = $this->helper->showProgress( $evaluatedCategories, $totalCategories );
			}
			
			$evaluatedCategories++;
		}
	}

	private function getInterimResults( $db, $category){
		$interimResult = array();
		$resourcesInCategoryQuery = $db->query( "SELECT COUNT(DISTINCT subject) AS count FROM join_categories_statements WHERE category = '$category'" );
		$resourcesInCategory = $resourcesInCategoryQuery->fetch_object()->count;
		$predicateObjectPairsQuery = $db->query( "SELECT DISTINCT predicate, object FROM join_categories_statements WHERE category = '$category'" );
		while ( $row = mysqli_fetch_row( $predicateObjectPairsQuery ) ) {
			$predicate = $row[0];
			$object = $row[1];
			$countQuery = $db->query( "SELECT COUNT(*) AS count FROM join_categories_statements WHERE category = '$category' AND predicate = '$predicate' AND object = '$object'" );
			$count = $countQuery->fetch_object()->count;
			$probability = (int)$count / (int)$resourcesInCategory;
			$interimResult[] = array(
				'predicate' => $predicate,
				'object' => $object,
				'probability' => $probability
			);
		}
		return $interimResult;
	}

	private function createSuggestions( $db, $interimResults, $category ) {
		foreach ( $interimResults as $result ) {
			$predicate = $result['predicate'];
			$object = $result['object'];
			$probability = $result['probability'];
			$itemsWithoutPairQuery = $db->query( "SELECT item FROM join_categories_statements WHERE category = '$category' AND NOT predicate = '$predicate' AND NOT object = '$object'" );
			if ( $itemsWithoutPairQuery ) {
				while ( $row = mysqli_fetch_row( $itemsWithoutPairQuery ) ) {
					$subject = $row[0];
					$status = 'D';
					if ( $probability > self::THRESHOLD_ADD ) {
						$status = 'A';

					} elseif ( $probability > self::THRESHOLD_REVIEW ) {
						$status = 'R';
					}
					$insert = "INSERT INTO suggestions (status, subject, predicate, object, probability) VALUES ('$status' '$subject', '$predicate', '$object', $probability)";
					$db->query( $insert );
				}
			}
		}
	}
}
