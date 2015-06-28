
DROP TABLE IF EXISTS 'suggestions_clear';
CREATE TABLE 'suggestions_clear' (
	'status' 	VARCHAR(7),
	'subject' 	VARCHAR(1000),
	'predicate' 	VARCHAR(1000),
	'object' 	VARCHAR(1000),
	'probability '	FLOAT,
	'category'	VARCHAR(1000)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS 'subjects_per_category_count_clear';
CREATE TABLE 'subjects_per_category_count_clear' (  
	'category'		VARCHAR(1000),
	'resource_count'	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;







#################################################
#		TRANSLATE CRC_MD5		#
#################################################

Drop PROCEDURE IF EXISTS translate_crc;

Delimiter $$

CREATE PROCEDURE translate_crc() 
BLOCK1: BEGIN 

	INSERT INTO 	crc_clear
	SELECT 		c2md5.category, crc.resource_count
	FROM 		crc_md5 AS crc 
	LEFT JOIN 	category_to_md5	AS c2md5 ON crc.category_md5 	= c2md5.category_md5;

END BLOCK1$$

Delimiter ;

#CALL translate_crc;


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

#CALL translate_suggestions;
