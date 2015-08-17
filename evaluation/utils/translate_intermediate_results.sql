# cs_join

DROP TABLE IF EXISTS `PFX_cs_join_clear`;
CREATE TABLE `PFX_cs_join_clear` (
	`category`	VARCHAR(1000),
	`subject` 	VARCHAR(1000),
	`predicate` 	VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO PFX_cs_join_clear
	SELECT c2md5.category, s2md5.resource, p2md5.predicate, o2md5.resource, cs.inverted
	FROM 		PFX_cs_join_md5 	AS cs
	LEFT JOIN 	PFX_all_rso_translation 	AS s2md5 ON cs.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	PFX_predicate_translation 	AS p2md5 ON cs.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	PFX_all_rso_translation 	AS o2md5 ON cs.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	PFX_category_translation	AS c2md5 ON cs.category_md5 	= c2md5.category_md5;

# subjects_per_category_count

DROP TABLE IF EXISTS `PFX_subjects_per_category_count_clear`;
CREATE TABLE `PFX_subjects_per_category_count_clear` (  
	`category`		VARCHAR(1000),
	`subject_count`		INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_subjects_per_category_count_clear
	SELECT 		c2md5.category, spc.subject_count
	FROM 		PFX_subjects_per_category_count_md5	AS spc 
	LEFT JOIN 	PFX_category_translation 		AS c2md5 
	ON 			spc.category_md5 = c2md5.category_md5;

# predicate_object_count

DROP TABLE IF EXISTS `PFX_predicate_object_count_clear`;
CREATE TABLE `PFX_predicate_object_count_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_predicate_object_count_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, poc.count, poc.inverted
	FROM 		PFX_predicate_object_count_md5 	AS poc
	LEFT JOIN 	PFX_category_translation		AS c2md5 ON poc.category_md5 	= c2md5.category_md5	
	LEFT JOIN 	PFX_predicate_translation 		AS p2md5 ON poc.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	PFX_all_rso_translation 		AS o2md5 ON poc.object_md5 	= o2md5.resource_md5;

# property_probability

DROP TABLE IF EXISTS `PFX_property_probability_clear`;
CREATE TABLE `PFX_property_probability_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_property_probability_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, pp.probability, pp.inverted
	FROM 		PFX_property_probability_md5 	AS pp
	LEFT JOIN 	PFX_category_translation		AS c2md5 ON pp.category_md5 	= c2md5.category_md5
	LEFT JOIN 	PFX_predicate_translation 		AS p2md5 ON pp.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	PFX_all_rso_translation 		AS o2md5 ON pp.object_md5 	= o2md5.resource_md5;

# cat_wo_stat

DROP TABLE IF EXISTS `PFX_cat_wo_stat_clear`;
CREATE TABLE `PFX_cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_cat_wo_stat_clear 
	SELECT 		r2md5.resource, c2md5.category
	FROM		PFX_cat_wo_stat_md5	  AS cws
	LEFT JOIN 	PFX_all_rso_translation	AS r2md5 ON cws.resource_md5 = r2md5.resource_md5
	LEFT JOIN 	PFX_category_translation	AS c2md5 ON cws.category_md5 = c2md5.category_md5;

# are_properties_functional

DROP TABLE IF EXISTS `PFX_are_properties_functional_clear`;
CREATE TABLE `PFX_are_properties_functional_clear` (
  `predicate`		varchar(1000) NOT NULL,
  `is_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_are_properties_functional_clear
SELECT trans.predicate, is_functional
FROM PFX_are_properties_functional_md5 md5
INNER JOIN PFX_predicate_translation trans
ON md5.predicate_md5 = trans.predicate_md5;

# property_stats

DROP TABLE IF EXISTS `PFX_property_stats_clear`;
CREATE TABLE `PFX_property_stats_clear` (
  `predicate`				varchar(1000) NOT NULL,
  `predicate_avg`			float NOT NULL,
  `is_functional`			tinyint(1) NOT NULL,
  `considered_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_property_stats_clear
SELECT trans.predicate, predicate_avg, is_functional, considered_functional
FROM PFX_property_stats_md5 md5
INNER JOIN PFX_predicate_translation trans
ON md5.predicate_md5 = trans.predicate_md5;

# functional_prop_suggestions

DROP TABLE IF EXISTS `PFX_functional_prop_suggestions_clear`;
CREATE TABLE `PFX_functional_prop_suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO PFX_functional_prop_suggestions_clear
	SELECT 		sug.status, s2md5.resource, p2md5.predicate, o2md5.resource, sug.probability, c2md5.category, sug.inverted
	FROM 		PFX_functional_prop_suggestions_md5 	AS sug
	LEFT JOIN 	PFX_all_rso_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	PFX_predicate_translation 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	PFX_all_rso_translation 	AS o2md5 ON sug.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	PFX_category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5;
