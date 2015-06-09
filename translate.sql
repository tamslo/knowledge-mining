

#################################################
#		TRANSLATE CRC_MD5		#
#################################################

Drop PROCEDURE IF EXISTS translate_crc;

Delimiter $$

CREATE PROCEDURE translate_crc() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_category 		varchar(127);
	DECLARE c_category_md5 		BINARY(16);
	DECLARE c_resource_count 	INT;

	DECLARE crc_cursor CURSOR FOR SELECT * FROM crc_md5; 
	DECLARE translate_cursor CURSOR FOR SELECT resource FROM hash_translation WHERE hash = c_category_md5;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;
	
	OPEN crc_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH crc_cursor INTO c_category_md5, c_resource_count; 
		 
		IF no_more_rows1 THEN 
			CLOSE crc_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		OPEN 	translate_cursor; 
		FETCH 	translate_cursor INTO c_category; 
		CLOSE 	translate_cursor; 

		INSERT INTO crc_clear VALUES(c_category, c_resource_count ); 
		
	END LOOP foreach_line_loop; 
END BLOCK1$$

Delimiter ;




#########################################################
#		TRANSLATE SUGGESTIONS_MD5		#
#########################################################

Drop PROCEDURE IF EXISTS translate_suggestions;

Delimiter $$

CREATE PROCEDURE translate_suggestions() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 boolean DEFAULT FALSE; 

	DECLARE c_category 		varchar(127);
	DECLARE c_subject 		varchar(127);
	DECLARE c_predicate 		varchar(127);
	DECLARE c_object 		varchar(127);

	DECLARE c_category_md5 		BINARY(16);
	DECLARE c_subject_md5 		BINARY(16);
	DECLARE c_predicate_md5		BINARY(16);
	DECLARE c_object_md5 		BINARY(16);

	DECLARE probability 		DECIMAL(2,2);
	DECLARE status			VARCHAR(7);

	DECLARE counter			INT;

	DECLARE suggestions_md5_cursor CURSOR FOR SELECT * FROM suggestions_md5; 


	DECLARE get_category	CURSOR FOR SELECT cleartext FROM hash_translation2 WHERE hash = c_category_md5;
	DECLARE get_subject	CURSOR FOR SELECT cleartext FROM hash_translation2 WHERE hash = c_subject_md5;
	DECLARE get_predicate	CURSOR FOR SELECT cleartext FROM hash_translation2 WHERE hash = c_predicate_md5;
	DECLARE get_object	CURSOR FOR SELECT cleartext FROM hash_translation2 WHERE hash = c_object_md5;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;
	
	SET counter= 0;


	OPEN suggestions_md5_cursor; 
	
	foreach_line_loop:LOOP 
		
		FETCH suggestions_md5_cursor INTO status, c_subject_md5, c_predicate_md5, c_object_md5, probability, c_category_md5; 
		 
		IF no_more_rows1 THEN 
			CLOSE suggestions_md5_cursor; 
			LEAVE foreach_line_loop; 
		END IF; 
	
		SET counter = counter +1;
		#SELECT counter;

		OPEN 	get_subject; 
		OPEN 	get_predicate;
		OPEN 	get_object; 
		OPEN 	get_category;

		FETCH 	get_subject 	INTO c_subject; 
		#FETCH 	get_predicate 	INTO c_predicate; 
		#FETCH 	get_object 	INTO c_object; 
		#FETCH 	get_category 	INTO c_category;
		  
		CLOSE 	get_subject;
		CLOSE 	get_predicate; 
		CLOSE 	get_object; 
		CLOSE 	get_category; 
	
		SELECT counter;

		#INSERT INTO suggestions VALUES(status, c_category, c_predicate, c_object, probability, c_category ); 
		
	END LOOP foreach_line_loop; 
END BLOCK1$$

Delimiter ;

