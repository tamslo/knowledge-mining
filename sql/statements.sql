SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;

DROP TABLE IF EXISTS statements;

CREATE TABLE statements (
	subject BINARY(16),
	predicate BINARY(16),
	object BINARY(16)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE ${statements_csv_path}
    INTO TABLE statements
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
    LINES TERMINATED BY '\n';
