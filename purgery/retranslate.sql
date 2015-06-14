

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

	
	INSERT INTO suggestions
	SELECT sug.status, s2md5.subject, p2md5.predicate, o2md5.object, sug.probability, c2md5.category
	FROM suggestions_md5 		AS sug
 	LEFT JOIN subject_to_md5 	AS s2md5 ON sug.subject_md5 	= s2md5.subject_md5
 	LEFT JOIN predicate_to_md5 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5
 	LEFT JOIN object_to_md5 	AS o2md5 ON sug.object_md5 	= o2md5.object_md5
	LEFT JOIN category_to_md5	AS c2md5 ON sug.category_md5 	= c2md5.category_md5; 
	
END BLOCK1$$

Delimiter ;

