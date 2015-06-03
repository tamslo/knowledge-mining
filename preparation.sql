SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;




#################################
#	LOAD CSV INTO DB	#
#################################
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS statements;


CREATE TABLE categories(
    category BINARY(16),
    resource BINARY(16)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


LOAD DATA LOCAL INFILE './categories.csv'
    INTO TABLE categories
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
    LINES TERMINATED BY '\n';

CREATE TABLE statements (
	subject BINARY(16),
	predicate BINARY(16),
	object BINARY(16)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE './statements.csv'
    INTO TABLE statements
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    ESCAPED BY '"'
    LINES TERMINATED BY '\n';









#################################
#		HASHING		#
#################################

DROP TABLE IF EXISTS categories_md5;
DROP TABLE IF EXISTS statements_md5;
DROP TABLE IF EXISTS hash_collisions;
DROP TABLE IF EXISTS hash_translation;
DROP TABLE IF EXISTS hashes_dup;
DROP TABLE IF EXISTS suggestions_md5;
DROP TABLE IF EXISTS crc_md5;
DROP TABLE IF EXISTS suggestions;
DROP TABLE IF EXISTS cs_join_md5;


CREATE TABLE cs_join_md5 (  
	category_md5 	BINARY(16), 
	subject_md5 	BINARY(16), 
	predicate_md5 	BINARY(16), 
	object_md5 	BINARY(16) 
);

CREATE TABLE suggestions_md5 (  
	status 		varchar(7), 
	subject_md5 	BINARY(16), 
	predicate_md5 	BINARY(16), 
	object_md5 	BINARY(16),
	probability	float 
);

CREATE TABLE suggestions (
	status 		VARCHAR(7),
	subject 	VARCHAR(127),
	predicate 	VARCHAR(127),
	object 		VARCHAR(127),
	probability FLOAT
);

CREATE TABLE crc_md5 (  
	category_md5 	BINARY(16),
	resource_count	INT
);







CREATE TABLE hash_collisions(
    hash BINARY(16),
    resource VARCHAR(127)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE hash_translation(
    hash BINARY(16),
    resource VARCHAR(127)
    ) ;

CREATE TABLE hashes_dup(
    hash BINARY(16),
    resource VARCHAR(127)
    ) ;





CREATE TABLE categories_md5(
    category_md5 BINARY(16),
    resource_md5 BINARY(16)
    ) ;

INSERT INTO categories_md5 SELECT UNHEX(MD5(category)), UNHEX(MD5(resource)) FROM categories;
CREATE INDEX category_md5_index ON categories_md5(resource_md5);






CREATE TABLE statements_md5 (
    subject_md5 BINARY(16),
    predicate_md5 BINARY(16),
    object_md5 BINARY(16)
) ;

INSERT INTO statements_md5 SELECT UNHEX(MD5(subject)), UNHEX(MD5(predicate)), UNHEX(MD5(object)) FROM statements;
CREATE INDEX subject_md5_index ON statements_md5(subject_md5);






INSERT INTO hashes_dup SELECT UNHEX(MD5(category)), category FROM categories;
INSERT INTO hashes_dup SELECT UNHEX(MD5(resource)), resource FROM categories;
INSERT INTO hashes_dup SELECT UNHEX(MD5(subject)), subject FROM statements;
INSERT INTO hashes_dup SELECT UNHEX(MD5(predicate)), predicate FROM statements;
INSERT INTO hashes_dup SELECT UNHEX(MD5(object)), object FROM statements;

# remove duplicate entries
INSERT INTO hash_translation SELECT * FROM hashes_dup WHERE 1 GROUP BY resource;
CREATE INDEX translate_crc ON hash_translation(hash, resource);

# detect hash collisions
INSERT INTO hash_collisions SELECT hash, resource FROM hash_translation GROUP BY hash HAVING count(*) >= 2;


#################################
#		JOIN		#
#################################
DROP PROCEDURE IF EXISTS exec_join;

DELIMITER $$

CREATE PROCEDURE exec_join() 
BLOCK1: BEGIN 

	INSERT INTO cs_join_md5 (
    		SELECT c.category_md5, s.subject_md5, s.predicate_md5, s.object_md5
		FROM categories_md5 AS c, statements_md5 AS s
		WHERE c.resource_md5 = s.subject_md5
		ORDER BY category_md5
	);
	create index md5_index on cs_join_md5(category_md5, subject_md5, predicate_md5, object_md5);
END BLOCK1$$


DELIMITER ;

