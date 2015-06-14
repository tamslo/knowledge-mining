#################################################
#		TRANSLATE category		#
#################################################

Drop PROCEDURE IF EXISTS cat_trans;

Delimiter $$

CREATE PROCEDURE cat_trans() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_category 		varchar(127);
	DECLARE c_category_md5		BINARY(16);
	DECLARE cat_cursor 		CURSOR FOR SELECT DISTINCT category FROM categories; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;
	
	CREATE TABLE category_trans(cleartext VARCHAR(127), hash BINARY(16) );

	OPEN cat_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH cat_cursor INTO c_category; 
		 
		IF no_more_rows1 THEN 
			CLOSE cat_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		#INSERT IGNORE INTO translation_table VALUES(c_category, unhex(md5(c_category)) );
		INSERT INTO category_trans VALUES(c_category, unhex(md5(c_category)) );	

	END LOOP foreach_line_loop; 
	
	CREATE INDEX cat_index on category_trans(hash);

END BLOCK1$$

Delimiter ;


#################################################
#		TRANSLATE resource		#
#################################################

Drop PROCEDURE IF EXISTS res_trans;

Delimiter $$

CREATE PROCEDURE res_trans() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_resource 		varchar(127);
	DECLARE c_resource_md5		BINARY(16);
	DECLARE res_cursor 		CURSOR FOR SELECT DISTINCT resource FROM categories; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;
	
	CREATE TABLE resource_trans(cleartext VARCHAR(127), hash BINARY(16) );

	OPEN res_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH res_cursor INTO c_resource; 
		 
		IF no_more_rows1 THEN 
			CLOSE res_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		#INSERT IGNORE INTO translation_table VALUES(c_resource, unhex(md5(c_resource)) );
		INSERT INTO resource_trans VALUES(c_resource, unhex(md5(c_resource)) );	
	
	END LOOP foreach_line_loop; 

	CREATE INDEX res_index on resource_trans(hash);

END BLOCK1$$

Delimiter ;
#################################################
#		TRANSLATE subject		#
#################################################

Drop PROCEDURE IF EXISTS sub_trans;

Delimiter $$

CREATE PROCEDURE sub_trans() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_subject 		varchar(127);
	DECLARE c_subject_md5		BINARY(16);
	DECLARE sub_cursor 		CURSOR FOR SELECT DISTINCT subject FROM statements; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;

	CREATE TABLE subject_trans(cleartext VARCHAR(127), hash BINARY(16) );
	
	OPEN sub_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH sub_cursor INTO c_subject; 
		 
		IF no_more_rows1 THEN 
			CLOSE sub_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		#INSERT IGNORE INTO translation_table VALUES(c_subject, unhex(md5(c_subject)) );
		INSERT INTO subject_trans VALUES(c_subject, unhex(md5(c_subject)) );	
	
	END LOOP foreach_line_loop; 

	CREATE INDEX sub_index on subject_trans(hash);

END BLOCK1$$

Delimiter ;


#################################################
#		TRANSLATE predicate		#
#################################################

Drop PROCEDURE IF EXISTS pred_trans;

Delimiter $$

CREATE PROCEDURE pred_trans() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_predicate 		varchar(127);
	DECLARE c_predicate_md5		BINARY(16);
	DECLARE pred_cursor 		CURSOR FOR SELECT DISTINCT predicate FROM statements; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;

	CREATE TABLE predicate_trans(cleartext VARCHAR(127), hash BINARY(16) );
	
	OPEN pred_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH pred_cursor INTO c_predicate; 
		 
		IF no_more_rows1 THEN 
			CLOSE pred_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		#INSERT IGNORE INTO translation_table VALUES(c_predicate, unhex(md5(c_predicate)) );
		INSERT INTO predicate_trans VALUES(c_predicate, unhex(md5(c_predicate)) );	
	
	END LOOP foreach_line_loop; 

	CREATE INDEX pred_index on predicate_trans(hash);

END BLOCK1$$

Delimiter ;

#################################################
#		TRANSLATE object		#
#################################################

Drop PROCEDURE IF EXISTS obj_trans;

Delimiter $$

CREATE PROCEDURE obj_trans() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_object 		varchar(127);
	DECLARE c_object_md5		BINARY(16);
	DECLARE obj_cursor 		CURSOR FOR SELECT DISTINCT object FROM statements; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;

	CREATE TABLE object_trans(cleartext VARCHAR(127), hash BINARY(16) );
	
	OPEN obj_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH obj_cursor INTO c_object; 
		 
		IF no_more_rows1 THEN 
			CLOSE obj_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		#INSERT IGNORE INTO translation_table VALUES(c_object, unhex(md5(c_object)) );
		INSERT INTO object_trans VALUES(c_object, unhex(md5(c_object)) );	
	
	END LOOP foreach_line_loop; 

	CREATE INDEX obj_index on object_trans(hash);

END BLOCK1$$

Delimiter ;
