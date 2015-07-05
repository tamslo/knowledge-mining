DROP TABLE IF EXISTS `suggestions_clear`;
CREATE TABLE `suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` 	VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO suggestions_clear
	SELECT sug.status, s2md5.subject, p2md5.predicate, o2md5.object, sug.probability, c2md5.category, sug.inverted
	FROM suggestions_md5 		AS sug
	LEFT JOIN subject_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.subject_md5	
	LEFT JOIN predicate_translation AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN object_translation 	AS o2md5 ON sug.object_md5 	= o2md5.object_md5	
	LEFT JOIN category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5
	WHERE sug.inverted IS FALSE;


INSERT INTO suggestions_clear
	SELECT sug.status, o2md5.object, p2md5.predicate, s2md5.subject, sug.probability, c2md5.category, sug.inverted
	FROM suggestions_md5 		AS sug
	LEFT JOIN object_translation 	AS o2md5 ON sug.object_md5 	= o2md5.object_md5	
	LEFT JOIN predicate_translation AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5
	LEFT JOIN subject_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.subject_md5 		
	LEFT JOIN category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5
	WHERE sug.inverted IS TRUE;

###########################################################################################


DROP TABLE IF EXISTS `subjects_per_category_count_clear`;
CREATE TABLE `subjects_per_category_count_clear` (  
	`category`		VARCHAR(1000),
	`subject_count`		INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO subjects_per_category_count_clear
	SELECT 		c2md5.category, spc.subject_count
	FROM 		subjects_per_category_count_md5 AS spc 
	LEFT JOIN 	category_translation AS c2md5 
	ON 		spc.category_md5 = c2md5.category_md5;


DROP TABLE IF EXISTS `predicate_object_count_clear`;
CREATE TABLE `predicate_object_count_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`count`		INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO predicate_object_count_clear
	SELECT c2md5.category, p2md5.predicate, o2md5.object, poc.count
	FROM predicate_object_count_md5 AS poc
	LEFT JOIN category_translation	AS c2md5 ON poc.category_md5 	= c2md5.category_md5	
	LEFT JOIN predicate_translation AS p2md5 ON poc.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN object_translation 	AS o2md5 ON poc.object_md5 	= o2md5.object_md5;


DROP TABLE IF EXISTS `property_probability_clear`;
CREATE TABLE `property_probability_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`probability`	float NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO property_probability_clear
	SELECT c2md5.category, p2md5.predicate, o2md5.object, pp.probability
	FROM property_probability_md5 	AS pp
	LEFT JOIN category_translation	AS c2md5 ON pp.category_md5 	= c2md5.category_md5
	LEFT JOIN predicate_translation AS p2md5 ON pp.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN object_translation 	AS o2md5 ON pp.object_md5 	= o2md5.object_md5;


### cleartext version for understanding
DROP TABLE IF EXISTS `cat_wo_stat_clear`;
CREATE TABLE `cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cat_wo_stat_clear 
	SELECT r2md5.resource, c2md5.category
	FROM	cat_wo_stat_md5	  AS cws
	LEFT JOIN resource_translation AS r2md5 ON cws.resource_md5 = r2md5.resource_md5
	LEFT JOIN category_translation AS c2md5 ON cws.category_md5 = c2md5.category_md5;




