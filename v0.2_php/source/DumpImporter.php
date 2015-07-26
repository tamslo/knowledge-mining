<?php

include_once "./Helper.php";

class DumpImporter {

	CONST CATEGORIES_DUMP_TYPE = 'categories';
	CONST STATEMENTS_DUMP_TYPE = 'statements';

	#private $categoriesDumpPath = 'dumps/article_categories_en.ttl';
	#private $statementsDumpPath = 'dumps/mappingbased_properties_en.ttl';
	private $categoriesDumpPath = 'dumps/article_categories_100000';
	private $statementsDumpPath = 'dumps/mappingbased_properties_100000';

	private $helper;

	public function __construct() {
		$this->helper = new Helper();
	}

	public function execute() {
		$db = $this->helper->getDB();

		$categoriesTable = 'categories';
		$categoriesColumns = array(
			'category' => 'VARCHAR(127)',
			'subject' => 'VARCHAR(127)'
		);
		$categoriesIndex = 'idx_categories_subjects';
		$categoriesIndexedColumns = array( 'subject' );

		$this->helper->createTable( $db, $categoriesTable, $categoriesColumns );
		$this->createIndex( $db, $categoriesTable, $categoriesIndex, $categoriesIndexedColumns );
		$this->processDump( $db, self::CATEGORIES_DUMP_TYPE );

		$statementsTable = 'statements';
		$statementsColumns = array(
			'subject' => 'VARCHAR(127)',
			'predicate' => 'VARCHAR(127)',
			'object' => 'VARCHAR(127)'
		);
		$statementsIndex = 'idx_statements_subjects';
		$statementsIndexedColumns = array( 'subject' );

		$this->helper->createTable( $db, $statementsTable, $statementsColumns );
		$this->createIndex( $db, $statementsTable, $statementsIndex, $statementsIndexedColumns );
		$this->processDump( $db, self::STATEMENTS_DUMP_TYPE );
	}

	private function processDump( $db, $type ) {

		if ( $type === self::CATEGORIES_DUMP_TYPE ) {
			$dumpPath = $this->categoriesDumpPath;
		} elseif ( $type === self::STATEMENTS_DUMP_TYPE ) {
			$dumpPath = $this->statementsDumpPath;
		}

		$totalLines = $this->countLines( $dumpPath );

		echo "Processing $dumpPath ...\n";

		$dump = $this->openDump( $dumpPath );

		$currentLine = 0;

		$done = False;

		while ( !feof( $dump ) ) {
			$line = fgets( $dump );

			if ( $line[0] === '<' ) {
				$currentLine++;
				$entities = $this->extractEntities( $line );
				if ( $type === self::CATEGORIES_DUMP_TYPE ) {
					$this->insertCategory( $db, $entities );
				} elseif ( $type === self::STATEMENTS_DUMP_TYPE ) {
					$this->insertStatement( $db, $entities );
				}
				if ( !$done ) {
					$done = $this->helper->showProgress( $currentLine, $totalLines );
				}
			}
		}
	}

	private function insertCategory( $db, $entities ) {
		$category = $entities['object'];
		$subject = $entities['subject'];
		$present = $db->query( "SELECT * FROM categories WHERE category = '$category' AND subject = '$subject'" );

		if ( $present ) {
			$insert = "INSERT INTO categories (category, subject) VALUES ('$category', '$subject')";
			$success = $db->query( $insert );
		} else {
			$success = true;
		}

		return $success;
	}

	private function insertStatement( $db, $entities ) {
		$subject = $entities['subject'];
		$predicate = $entities['predicate'];
		$object = $entities['object'];
		$insert = "INSERT INTO statements (subject, predicate, object) VALUES ('$subject', '$predicate', '$object')";
		$success = $db->query( $insert );
		return $success;
	}

	private function extractEntities( $line ) {
		if ( $line[ strlen( $line ) - 1 ] === "\n" ) {
			$line = substr( $line, 0, -1 );
		}
		if ( $line[ strlen( $line ) - 1 ] === '.' ) {
			$line = substr( $line, 0, -1 );
		}
		if ( $line[ strlen( $line ) - 1 ] === ' ' ) {
			$line = substr( $line, 0, -1 );
		}

		$currentEntity = 'subject';
		$entities = array(
			'subject' => '',
			'predicate' => '',
			'object' => ''
		);
		for ( $position = 0; $position < strlen( $line ); $position++ ) {
			$char = $line[ $position ];
			if ( $char === ' ' ) {
				if ($currentEntity === 'subject') {
					$currentEntity = 'predicate';
					continue;
				} elseif ($currentEntity === 'predicate') {
					$currentEntity = 'object';
					continue;
				} else {
					$entities[ $currentEntity ] = $entities[ $currentEntity ] . $char;
				}
			}
			else {
				$entities[ $currentEntity ] = $entities[ $currentEntity ] . $char;
			}
		}

		return $entities;
	}

	private function createIndex( $db, $table, $index, $columns ) {
		$columns = implode( ',', $columns );
		$createIndex = "CREATE INDEX $index ON $table ($columns);";
		$success = $db->query( $createIndex );
		return $success;
	}

	private function countLines( $dumpPath ) {
		echo "Preparing $dumpPath ...\n";
		$dump = $this->openDump( $dumpPath );
		$totalLines = 0;
		while ( !feof( $dump ) ) {
			$line = fgets( $dump );
			if ( $line[0] === '<' ) {
				$totalLines++;
			}
		}
		return $totalLines;
	}

	private function openDump( $dumpPath ) {
		$cwd = getcwd();
		chdir('../');
		$dump = fopen( $dumpPath, 'r' );
		chdir( $cwd );
		return $dump;
	}
}
