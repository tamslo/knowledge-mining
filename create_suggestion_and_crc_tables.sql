DROP TABLE IF EXISTS suggestions_md5;
DROP TABLE IF EXISTS suggestions;
DROP TABLE IF EXISTS crc_md5;
DROP TABLE IF EXISTS crc_clear;


CREATE TABLE suggestions_md5 (  
	status 		varchar(7), 
	subject_md5 	CHAR(32), 
	predicate_md5 	CHAR(32), 
	object_md5 	CHAR(32),
	probability	float, 
	category_md5	CHAR(32)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE suggestions (
	status 		VARCHAR(7),
	subject 	VARCHAR(1000),
	predicate 	VARCHAR(1000),
	object 		VARCHAR(1000),
	probability 	FLOAT,
	category	VARCHAR(1000)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE crc_md5 (  
	category_md5 	CHAR(32),
	resource_count	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE crc_clear (  
	category 	VARCHAR(1000),
	resource_count	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
