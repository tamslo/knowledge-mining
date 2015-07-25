# Some basic parameter tuning
SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;

# Tables to import data

DROP TABLE IF EXISTS `EVAL_categories_original`;
CREATE TABLE `EVAL_categories_original` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `EVAL_statements_original`;
CREATE TABLE `EVAL_statements_original` (
  `subject` 	varchar(1000) NOT NULL,
  `predicate` 	varchar(1000) NOT NULL,
  `object` 	varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# Tables for suggestion cleansing

DROP TABLE IF EXISTS `EVAL_redirects_original`;
CREATE TABLE `EVAL_redirects_original` (
  `resource` varchar(1000) NOT NULL,
  `redirect` varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `EVAL_functional_properties`;
CREATE TABLE `EVAL_functional_properties` (
  `predicate`	varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/test_categories.csv' INTO TABLE EVAL_categories_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/test_statements.csv' INTO TABLE EVAL_statements_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/redirects.csv' INTO TABLE EVAL_redirects_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/func_prop.csv' INTO TABLE EVAL_functional_properties FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\\' LINES TERMINATED BY '\n';

#################################################################################################################################################################################

# Clean data from lists

DELETE FROM EVAL_categories_original WHERE resource LIKE 'http://dbpedia.org/resource/List\_of\_%';
DELETE FROM EVAL_statements_original WHERE subject LIKE 'http://dbpedia.org/resource/List\_of\_%';

#################################################################################################################################################################################

# Translate tables to md5 and create tables for re-translation

DROP TABLE IF EXISTS `EVAL_categories_md5`;
CREATE TABLE `EVAL_categories_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_categories_md5 SELECT md5(resource),md5(category) FROM  EVAL_categories_original;

ALTER TABLE `EVAL_categories_md5` 
ADD INDEX `idx_categories_md5_resource` (`resource_md5` ASC),
ADD INDEX `idx_categories_md5_category` (`category_md5` ASC);

DROP TABLE IF EXISTS `EVAL_statements_md5`;
CREATE TABLE `EVAL_statements_md5` (
  `subject_md5`		char(32) NOT NULL,
  `predicate_md5`	char(32) NOT NULL,
  `object_md5`		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_statements_md5 SELECT md5(subject), md5(predicate), md5(object) FROM EVAL_statements_original;

ALTER TABLE `EVAL_statements_md5` 
ADD INDEX `idx_statements_md5_subject`	(`subject_md5` ASC),
ADD INDEX `idx_statements_md5_predicate` (`predicate_md5` ASC),
ADD INDEX `idx_statements_md5_object` (`object_md5` ASC);

DROP TABLE IF EXISTS `EVAL_redirects_md5`;
CREATE TABLE `EVAL_redirects_md5` (
  `resource_md5` char(32) NOT NULL,
  `redirect_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_redirects_md5 SELECT md5(resource),md5(redirect) FROM  EVAL_redirects_original;

ALTER TABLE `EVAL_redirects_md5` 
ADD INDEX `idx_redirects_md5_resource` (`resource_md5` ASC),
ADD INDEX `idx_redirects_md5_redirect` (`redirect_md5` ASC);

DROP TABLE IF EXISTS `EVAL_category_translation`;
CREATE TABLE `EVAL_category_translation` (
  `category` 		varchar(1000) 	NOT NULL,
  `category_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`category_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_category_translation SELECT category,md5(category) FROM EVAL_categories_original;

DROP TABLE IF EXISTS `EVAL_predicate_translation`;
CREATE TABLE `EVAL_predicate_translation` (
  `predicate` 		varchar(1000) 	NOT NULL,
  `predicate_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`predicate_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_predicate_translation SELECT predicate,md5(predicate) FROM EVAL_statements_original;

DROP TABLE IF EXISTS `EVAL_all_rso_translation`;
CREATE TABLE `EVAL_all_rso_translation` (
  `resource` 		varchar(1000) 	NOT NULL,
  `resource_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`resource_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_all_rso_translation SELECT resource,md5(resource)	FROM EVAL_categories_original;
INSERT IGNORE INTO EVAL_all_rso_translation SELECT subject,md5(subject) 	FROM EVAL_statements_original;
INSERT IGNORE INTO EVAL_all_rso_translation SELECT object,md5(object) 	FROM EVAL_statements_original;
INSERT IGNORE INTO EVAL_all_rso_translation SELECT resource,md5(resource)  FROM EVAL_redirects_original;
INSERT IGNORE INTO EVAL_all_rso_translation SELECT redirect,md5(redirect)  FROM EVAL_redirects_original;

#################################################################################################################################################################################

# Clean data from redirects

DELETE FROM EVAL_statements_md5 WHERE subject_md5 IN(SELECT resource_md5 FROM EVAL_redirects_md5);
DELETE FROM EVAL_categories_md5 WHERE resource_md5 IN(SELECT resource_md5 FROM EVAL_redirects_md5);

#################################################################################################################################################################################

# Join categories and statements

DROP TABLE IF EXISTS `EVAL_cs_join_md5`;
CREATE TABLE `EVAL_cs_join_md5` (
	`category_md5`	CHAR(32),
	`subject_md5`	CHAR(32),
	`predicate_md5`	CHAR(32),
	`object_md5`	CHAR(32),
	`inverted`	tinyint(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 	EVAL_cs_join_md5 
	SELECT		c.category_md5, st.subject_md5, st.predicate_md5, st.object_md5, FALSE 
	FROM		EVAL_categories_md5 AS c
	INNER JOIN 	EVAL_statements_md5 AS st
	ON 			c.resource_md5 = st.subject_md5;

DROP TABLE IF EXISTS `EVAL_cat_wo_stat_md5`;
CREATE TABLE `EVAL_cat_wo_stat_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
INSERT INTO 	EVAL_cat_wo_stat_md5 
	SELECT		c.resource_md5, c.category_md5 
	FROM		EVAL_categories_md5 AS c
	LEFT JOIN 	EVAL_statements_md5 AS st
	ON 			c.resource_md5 = st.subject_md5
	WHERE		st.subject_md5 IS NULL;

CREATE INDEX `cws_md5_resource` on `EVAL_cat_wo_stat_md5`(`resource_md5`);
CREATE INDEX `cws_md5_category` on `EVAL_cat_wo_stat_md5`(`category_md5`);

INSERT INTO 	EVAL_cs_join_md5 
	SELECT		cwo.category_md5, st.object_md5, st.predicate_md5, st.subject_md5, TRUE 
	FROM		EVAL_cat_wo_stat_md5 AS cwo
	INNER JOIN 	EVAL_statements_md5 AS st
	ON 			cwo.resource_md5 = st.object_md5;

CREATE INDEX `idx_cs_join_md5_category`	on `EVAL_cs_join_md5`(`category_md5`);
CREATE INDEX `idx_cs_join_md5_cpo` 	on `EVAL_cs_join_md5`(`category_md5`, `predicate_md5`, `object_md5`);
CREATE INDEX `idx_cs_join_md5_subject` 	on `EVAL_cs_join_md5`(`subject_md5`);

#################################################################################################################################################################################

# Precomputation of intermediate results

DROP TABLE IF EXISTS `EVAL_subjects_per_category_count_md5`;
CREATE TABLE `EVAL_subjects_per_category_count_md5`(
	`category_md5` 	CHAR(32),
	`subject_count`	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_subjects_per_category_count_md5 
	SELECT 		distinct category_md5, COUNT(distinct resource_md5) 
	FROM 		EVAL_categories_md5 
	GROUP BY 	category_md5; 
CREATE INDEX `idx_spc_category` ON `EVAL_subjects_per_category_count_md5`(`category_md5`);

DROP TABLE IF EXISTS `EVAL_predicate_object_count_md5`;
CREATE TABLE `EVAL_predicate_object_count_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_predicate_object_count_md5
	SELECT 		cs.category_md5, cs.predicate_md5, cs.object_md5, COUNT(DISTINCT cs.subject_md5), cs.inverted
	FROM 		EVAL_cs_join_md5 AS cs
	LEFT JOIN	EVAL_subjects_per_category_count_md5 AS spc
	ON			cs.category_md5 = spc.category_md5
	WHERE		spc.subject_count >2
	GROUP BY	cs.category_md5, cs.predicate_md5, cs.object_md5;
CREATE INDEX `idx_poc_md5_category` 	ON `EVAL_predicate_object_count_md5`(`category_md5`);
CREATE INDEX `idx_poc_md5_count` 	ON `EVAL_predicate_object_count_md5`(`count`);


DROP TABLE IF EXISTS `EVAL_property_probability_md5`;
CREATE TABLE `EVAL_property_probability_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_property_probability_md5 
	SELECT 		poc.category_md5, poc.predicate_md5, poc.object_md5, (poc.count/spc.subject_count), poc.inverted
	FROM 		EVAL_predicate_object_count_md5 	AS poc
	LEFT JOIN	EVAL_subjects_per_category_count_md5 AS spc
	ON			poc.category_md5 = spc.category_md5;

CREATE INDEX `idx_pp_category` 	ON `EVAL_property_probability_md5`(`category_md5`);
CREATE INDEX `idx_pp_cpo` 	ON `EVAL_property_probability_md5`(`category_md5`, `predicate_md5`, `object_md5`);

#################################################################################################################################################################################

# Precomputation of functional properties

DROP TABLE IF EXISTS `EVAL_are_properties_functional_md5`;
CREATE TABLE `EVAL_are_properties_functional_md5` (
  `predicate_md5`	char(32) NOT NULL,
  `is_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_are_properties_functional_md5
SELECT md5(predicate), 1
FROM EVAL_functional_properties;


INSERT INTO EVAL_are_properties_functional_md5
SELECT DISTINCT predicate_md5, 0
FROM EVAL_predicate_translation
WHERE predicate_md5
NOT IN (SELECT DISTINCT predicate_md5 FROM EVAL_are_properties_functional_md5);

DROP TABLE IF EXISTS `EVAL_property_stats_md5`;
CREATE TABLE `EVAL_property_stats_md5` (
  `predicate_md5` 			varchar(1000) NOT NULL,
  `predicate_avg`			double NOT NULL,
  `is_functional`			tinyint(1) NOT NULL,
  `considered_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_property_stats_md5
SELECT avgs.predicate_md5, avg, is_functional, 0
FROM
	(SELECT predicate_md5, AVG(count) AS avg
	FROM
		(SELECT subject_md5, predicate_md5, COUNT(predicate_md5) AS count
		FROM EVAL_statements_md5
		GROUP BY subject_md5, predicate_md5) counts
	GROUP BY predicate_md5) avgs
	INNER JOIN EVAL_are_properties_functional_md5 fp
	ON avgs.predicate_md5 = fp.predicate_md5
ORDER BY avg;

UPDATE EVAL_property_stats_md5
SET considered_functional = 1
WHERE is_functional = 1
OR predicate_avg = 1;

#################################################################################################################################################################################

# Create suggestions

DROP TABLE IF EXISTS `EVAL_suggestions_md5`;
CREATE TABLE `EVAL_suggestions_md5` (  
	`status` 		varchar(7), 
	`subject_md5` 	CHAR(32), 
	`predicate_md5` CHAR(32), 
	`object_md5` 	CHAR(32),
	`probability`	float, 
	`category_md5`	CHAR(32),
	`inverted`		tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_suggestions_md5
	SELECT "A" AS status, ca.resource_md5 AS subject_md5, pp.predicate_md5, pp.object_md5, pp.probability, pp.category_md5, pp.inverted
    	FROM
    		(SELECT 	pp.predicate_md5, pp.object_md5, pp.probability, pp.category_md5, pp.inverted
    			FROM 	EVAL_property_probability_md5 AS pp
    			WHERE	pp.probability        >= 0.9
        		AND		pp.probability        < 1) AS pp
    
	JOIN 		EVAL_categories_md5 	AS ca 	ON pp.category_md5 	= ca.category_md5

	LEFT JOIN 	EVAL_cs_join_md5 	AS st 	ON st.subject_md5 	= ca.resource_md5 
										AND st.predicate_md5	= pp.predicate_md5 
										AND st.object_md5 	= pp.object_md5
    WHERE st.predicate_md5 IS NULL 
	AND st.object_md5 IS NULL;

#################################################################################################################################################################################

# Clean suggestions from selflinks

DELETE FROM EVAL_suggestions_md5 WHERE subject_md5 = object_md5;

#################################################################################################################################################################################

# Clean suggestions from functional properties

DROP TABLE IF EXISTS `EVAL_functional_prop_suggestions_md5`;
CREATE TABLE `EVAL_functional_prop_suggestions_md5` (  
	`status` 		varchar(7), 
	`subject_md5` 	CHAR(32), 
	`predicate_md5` CHAR(32), 
	`object_md5` 	CHAR(32),
	`probability`	float, 
	`category_md5`	CHAR(32),
	`inverted`		tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_functional_prop_suggestions_md5
SELECT *
FROM EVAL_suggestions_md5
WHERE EXISTS (SELECT * FROM EVAL_statements_md5 st
	WHERE EVAL_suggestions_md5.subject_md5 = st.subject_md5
	AND EVAL_suggestions_md5.predicate_md5 = st.predicate_md5)
AND EVAL_suggestions_md5.predicate_md5 IN (SELECT predicate_md5 FROM EVAL_property_stats_md5 WHERE considered_functional = 1);

DELETE FROM EVAL_suggestions_md5
WHERE EXISTS (SELECT * FROM EVAL_statements_md5 st
	WHERE EVAL_suggestions_md5.subject_md5 = st.subject_md5
	AND EVAL_suggestions_md5.predicate_md5 = st.predicate_md5)
AND EVAL_suggestions_md5.predicate_md5 IN (SELECT predicate_md5 FROM EVAL_property_stats_md5 WHERE considered_functional = 1);

#################################################################################################################################################################################

# Re-translate suggestions

DROP TABLE IF EXISTS `EVAL_suggestions_clear`;
CREATE TABLE `EVAL_suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_suggestions_clear
	SELECT 		sug.status, s2md5.resource, p2md5.predicate, o2md5.resource, sug.probability, c2md5.category, sug.inverted
	FROM 		EVAL_suggestions_md5 	AS sug
	LEFT JOIN 	EVAL_all_rso_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	EVAL_predicate_translation 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	EVAL_all_rso_translation 	AS o2md5 ON sug.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	EVAL_category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5;

#################################################################################################################################################################################

# Re-translate other tables to reconstruct results

DROP TABLE IF EXISTS `EVAL_subjects_per_category_count_clear`;
CREATE TABLE `EVAL_subjects_per_category_count_clear` (  
	`category`		VARCHAR(1000),
	`subject_count`		INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_subjects_per_category_count_clear
	SELECT 		c2md5.category, spc.subject_count
	FROM 		EVAL_subjects_per_category_count_md5	AS spc 
	LEFT JOIN 	EVAL_category_translation 		AS c2md5 
	ON 			spc.category_md5 = c2md5.category_md5;


DROP TABLE IF EXISTS `EVAL_predicate_object_count_clear`;
CREATE TABLE `EVAL_predicate_object_count_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_predicate_object_count_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, poc.count, poc.inverted
	FROM 		EVAL_predicate_object_count_md5 	AS poc
	LEFT JOIN 	EVAL_category_translation		AS c2md5 ON poc.category_md5 	= c2md5.category_md5	
	LEFT JOIN 	EVAL_predicate_translation 		AS p2md5 ON poc.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	EVAL_all_rso_translation 		AS o2md5 ON poc.object_md5 	= o2md5.resource_md5;


DROP TABLE IF EXISTS `EVAL_property_probability_clear`;
CREATE TABLE `EVAL_property_probability_clear`(
	`category`	VARCHAR(1000) NOT NULL,
	`predicate`	VARCHAR(1000) NOT NULL,
	`object`	VARCHAR(1000) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_property_probability_clear
	SELECT 		c2md5.category, p2md5.predicate, o2md5.resource, pp.probability, pp.inverted
	FROM 		EVAL_property_probability_md5 	AS pp
	LEFT JOIN 	EVAL_category_translation		AS c2md5 ON pp.category_md5 	= c2md5.category_md5
	LEFT JOIN 	EVAL_predicate_translation 		AS p2md5 ON pp.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	EVAL_all_rso_translation 		AS o2md5 ON pp.object_md5 	= o2md5.resource_md5;

DROP TABLE IF EXISTS `EVAL_cat_wo_stat_clear`;
CREATE TABLE `EVAL_cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_cat_wo_stat_clear 
	SELECT 		r2md5.resource, c2md5.category
	FROM		EVAL_cat_wo_stat_md5	  AS cws
	LEFT JOIN 	EVAL_all_rso_translation	AS r2md5 ON cws.resource_md5 = r2md5.resource_md5
	LEFT JOIN 	EVAL_category_translation	AS c2md5 ON cws.category_md5 = c2md5.category_md5;

DROP TABLE IF EXISTS `EVAL_are_properties_functional_clear`;
CREATE TABLE `EVAL_are_properties_functional_clear` (
  `predicate`		varchar(1000) NOT NULL,
  `is_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_are_properties_functional_clear
SELECT trans.predicate, is_functional
FROM EVAL_are_properties_functional_md5 md5
INNER JOIN EVAL_predicate_translation trans
ON md5.predicate_md5 = trans.predicate_md5;

DROP TABLE IF EXISTS `EVAL_property_stats_clear`;
CREATE TABLE `EVAL_property_stats_clear` (
  `predicate`				varchar(1000) NOT NULL,
  `predicate_avg`			float NOT NULL,
  `is_functional`			tinyint(1) NOT NULL,
  `considered_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_property_stats_clear
SELECT trans.predicate, predicate_avg, is_functional, considered_functional
FROM EVAL_property_stats_md5 md5
INNER JOIN EVAL_predicate_translation trans
ON md5.predicate_md5 = trans.predicate_md5;

DROP TABLE IF EXISTS `EVAL_functional_prop_suggestions_clear`;
CREATE TABLE `EVAL_functional_prop_suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_functional_prop_suggestions_clear
	SELECT 		sug.status, s2md5.resource, p2md5.predicate, o2md5.resource, sug.probability, c2md5.category, sug.inverted
	FROM 		EVAL_functional_prop_suggestions_md5 	AS sug
	LEFT JOIN 	EVAL_all_rso_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	EVAL_predicate_translation 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	EVAL_all_rso_translation 	AS o2md5 ON sug.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	EVAL_category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5;
