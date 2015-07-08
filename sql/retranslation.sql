DROP TABLE IF EXISTS `MK_TEST_suggestions_clear`;
CREATE TABLE `MK_TEST_suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` 	VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO MK_TEST_suggestions_clear
	SELECT sug.status, s2md5.resource, p2md5.predicate, o2md5.resource, sug.probability, c2md5.category, sug.inverted
	FROM 		MK_TEST_suggestions_md5 	AS sug
	LEFT JOIN 	MK_TEST_all_rso_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	MK_TEST_predicate_translation 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	MK_TEST_all_rso_translation 	AS o2md5 ON sug.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	MK_TEST_category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5;


###########################################################################################


DROP TABLE IF EXISTS `MK_TEST_subjects_per_category_count_clear`;
CREATE TABLE `MK_TEST_subjects_per_category_count_clear` (  
	`category`		VARCHAR(1000),
	`subject_count`		INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_subjects_per_category_count_clear
	SELECT 		c2md5.category, spc.subject_count
	FROM 		MK_TEST_subjects_per_category_count_md5	AS spc 
	LEFT JOIN 	MK_TEST_category_translation 		AS c2md5 
	ON 		spc.category_md5 = c2md5.category_md5;


DROP TABLE IF EXISTS `MK_TEST_predicate_object_count_clear`;
CREATE TABLE `MK_TEST_predicate_object_count_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_predicate_object_count_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, poc.count, poc.inverted
	FROM 		MK_TEST_predicate_object_count_md5 	AS poc
	LEFT JOIN 	MK_TEST_category_translation		AS c2md5 ON poc.category_md5 	= c2md5.category_md5	
	LEFT JOIN 	MK_TEST_predicate_translation 		AS p2md5 ON poc.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	MK_TEST_all_rso_translation 		AS o2md5 ON poc.object_md5 	= o2md5.resource_md5;


DROP TABLE IF EXISTS `MK_TEST_property_probability_clear`;
CREATE TABLE `MK_TEST_property_probability_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_property_probability_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, pp.probability, pp.inverted
	FROM 		MK_TEST_property_probability_md5 	AS pp
	LEFT JOIN 	MK_TEST_category_translation		AS c2md5 ON pp.category_md5 	= c2md5.category_md5
	LEFT JOIN 	MK_TEST_predicate_translation 		AS p2md5 ON pp.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	MK_TEST_all_rso_translation 		AS o2md5 ON pp.object_md5 	= o2md5.resource_md5;

DROP TABLE IF EXISTS `MK_TEST_cat_wo_stat_clear`;
CREATE TABLE `MK_TEST_cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_cat_wo_stat_clear 
	SELECT 		r2md5.resource, c2md5.category
	FROM		MK_TEST_cat_wo_stat_md5	  AS cws
	LEFT JOIN 	MK_TEST_all_rso_translation	AS r2md5 ON cws.resource_md5 = r2md5.resource_md5
	LEFT JOIN 	MK_TEST_category_translation	AS c2md5 ON cws.category_md5 = c2md5.category_md5;

