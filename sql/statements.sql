SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;

DROP TABLE IF EXISTS statements;

CREATE TABLE statements (
	subject VARCHAR(127),
	predicate VARCHAR(127),
	object VARCHAR(127)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA INFILE 'path_to_stateents.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';