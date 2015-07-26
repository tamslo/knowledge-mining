<?php

class Helper {

	private $dbParams = array(
		'server' => 'localhost',
		'user' => 'root',
		'password' => '1234',
		'name' => 'knowmin-mik'
	);

	public function getDB() {
		return new mysqli( $this->dbParams[ 'server' ], $this->dbParams[ 'user' ], $this->dbParams[ 'password' ], $this->dbParams[ 'name' ] );
	}

	public function showProgress( $current, $total ) {
		$progress = $current / $total;
		$progress = number_format($progress * 100, 2);
		$done = False;
		if ( $progress === "100.00" ) {
			echo "Progress: $progress%\n";
			$done = True;
		} else {
			echo "Progress: $progress%\r";
		}
		return $done;
	}

	public function createTable( $db, $table, $columns ) {
		$createTable = "CREATE TABLE $table (";
		$i = 1;
		$j = count( $columns );
		foreach ( $columns as $column => $columnType ) {
			if ( $i === $j ) {
				$createTable = $createTable . "$column $columnType);";
			} else {
				$createTable = $createTable . "$column $columnType,";
			}
			$i++;
		}
		$success = $db->query( $createTable );
		return $success;
	}
}