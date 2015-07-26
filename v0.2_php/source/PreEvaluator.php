<?php

include_once "./Helper.php";

class PreEvaluator {

	private $helper;
	public function __construct(){
		$this->helper = new Helper();
	}

	public function execute() {
		$db = $this->helper->getDB();

		$joinTable = 'join_categories_statements';
		$joinColumns = array(
			'category' => 'VARCHAR(127)',
			'subject' => 'VARCHAR(127)',
			'predicate' => 'VARCHAR(127)',
			'object' => 'VARCHAR(127)'
		);
		$this->helper->createTable( $db, $joinTable, $joinColumns );
		$this->insertIntoJoinTable( $db );

		$suggestionsTable = 'suggestions';
		$suggestionsColumns = array(
			'status' => 'VARCHAR(7)',
			'subject' => 'VARCHAR(127)',
			'predicate' => 'VARCHAR(127)',
			'object' => 'VARCHAR(127)',
			'probability' => 'FLOAT'
		);
		$this->helper->createTable( $db, $suggestionsTable, $suggestionsColumns );
	}

	private function insertIntoJoinTable( $db ) {
		echo "Joining categories and statements (this will take a while) ...\n";
		$insert = "INSERT INTO join_categories_statements (category, subject, predicate, object) ";
		$insert = $insert . "(SELECT c.category AS category, s.subject AS subject, s.predicate AS predicate, s.object AS object ";
		$insert = $insert . "FROM statements AS s, categories AS c ";
		$insert = $insert . "WHERE s.subject = c.subject ";
		$insert = $insert . "ORDER BY category);";
		$success = $db->query( $insert );
		return $success;
	}
	// TODO after that: maybe delete categories and statements (more space)

}
