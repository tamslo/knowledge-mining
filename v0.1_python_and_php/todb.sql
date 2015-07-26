# Translate tables to md5 and create tables for re-translation

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_categories_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_categories_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_categories_md5 SELECT md5(resource),md5(category) FROM  EVAL_NO_CLEANSING_categories_original;

ALTER TABLE `EVAL_NO_CLEANSING_categories_md5` 
ADD INDEX `idx_categories_md5_resource` (`resource_md5` ASC),
ADD INDEX `idx_categories_md5_category` (`category_md5` ASC);

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_statements_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_statements_md5` (
  `subject_md5`		char(32) NOT NULL,
  `predicate_md5`	char(32) NOT NULL,
  `object_md5`		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_statements_md5 SELECT md5(subject), md5(predicate), md5(object) FROM EVAL_NO_CLEANSING_statements_original;

ALTER TABLE `EVAL_NO_CLEANSING_statements_md5` 
ADD INDEX `idx_statements_md5_subject`	(`subject_md5` ASC),
ADD INDEX `idx_statements_md5_predicate` (`predicate_md5` ASC),
ADD INDEX `idx_statements_md5_object` (`object_md5` ASC);

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_category_translation`;
CREATE TABLE `EVAL_NO_CLEANSING_category_translation` (
  `category` 		varchar(1000) 	NOT NULL,
  `category_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`category_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_NO_CLEANSING_category_translation SELECT category,md5(category) FROM EVAL_NO_CLEANSING_categories_original;

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_predicate_translation`;
CREATE TABLE `EVAL_NO_CLEANSING_predicate_translation` (
  `predicate` 		varchar(1000) 	NOT NULL,
  `predicate_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`predicate_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_NO_CLEANSING_predicate_translation SELECT predicate,md5(predicate) FROM EVAL_NO_CLEANSING_statements_original;

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_all_rso_translation`;
CREATE TABLE `EVAL_NO_CLEANSING_all_rso_translation` (
  `resource` 		varchar(1000) 	NOT NULL,
  `resource_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`resource_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO EVAL_NO_CLEANSING_all_rso_translation SELECT resource,md5(resource)	FROM EVAL_NO_CLEANSING_categories_original;
INSERT IGNORE INTO EVAL_NO_CLEANSING_all_rso_translation SELECT subject,md5(subject) 	FROM EVAL_NO_CLEANSING_statements_original;
INSERT IGNORE INTO EVAL_NO_CLEANSING_all_rso_translation SELECT object,md5(object) 	FROM EVAL_NO_CLEANSING_statements_original;

#################################################################################################################################################################################

# Join categories and statements

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_cs_join_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_cs_join_md5` (
	`category_md5`	CHAR(32),
	`subject_md5`	CHAR(32),
	`predicate_md5`	CHAR(32),
	`object_md5`	CHAR(32),
	`inverted`	tinyint(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 	EVAL_NO_CLEANSING_cs_join_md5 
	SELECT		c.category_md5, st.subject_md5, st.predicate_md5, st.object_md5, FALSE 
	FROM		EVAL_NO_CLEANSING_categories_md5 AS c
	INNER JOIN 	EVAL_NO_CLEANSING_statements_md5 AS st
	ON 			c.resource_md5 = st.subject_md5;

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_cat_wo_stat_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_cat_wo_stat_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
INSERT INTO 	EVAL_NO_CLEANSING_cat_wo_stat_md5 
	SELECT		c.resource_md5, c.category_md5 
	FROM		EVAL_NO_CLEANSING_categories_md5 AS c
	LEFT JOIN 	EVAL_NO_CLEANSING_statements_md5 AS st
	ON 			c.resource_md5 = st.subject_md5
	WHERE		st.subject_md5 IS NULL;

CREATE INDEX `cws_md5_resource` on `EVAL_NO_CLEANSING_cat_wo_stat_md5`(`resource_md5`);
CREATE INDEX `cws_md5_category` on `EVAL_NO_CLEANSING_cat_wo_stat_md5`(`category_md5`);

INSERT INTO 	EVAL_NO_CLEANSING_cs_join_md5 
	SELECT		cwo.category_md5, st.object_md5, st.predicate_md5, st.subject_md5, TRUE 
	FROM		EVAL_NO_CLEANSING_cat_wo_stat_md5 AS cwo
	INNER JOIN 	EVAL_NO_CLEANSING_statements_md5 AS st
	ON 			cwo.resource_md5 = st.object_md5;

CREATE INDEX `idx_cs_join_md5_category`	on `EVAL_NO_CLEANSING_cs_join_md5`(`category_md5`);
CREATE INDEX `idx_cs_join_md5_cpo` 	on `EVAL_NO_CLEANSING_cs_join_md5`(`category_md5`, `predicate_md5`, `object_md5`);
CREATE INDEX `idx_cs_join_md5_subject` 	on `EVAL_NO_CLEANSING_cs_join_md5`(`subject_md5`);

#################################################################################################################################################################################

# Precomputation of intermediate results

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_subjects_per_category_count_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_subjects_per_category_count_md5`(
	`category_md5` 	CHAR(32),
	`subject_count`	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_subjects_per_category_count_md5 
	SELECT 		distinct category_md5, COUNT(distinct resource_md5) 
	FROM 		EVAL_NO_CLEANSING_categories_md5 
	GROUP BY 	category_md5; 
CREATE INDEX `idx_spc_category` ON `EVAL_NO_CLEANSING_subjects_per_category_count_md5`(`category_md5`);

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_predicate_object_count_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_predicate_object_count_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_predicate_object_count_md5
	SELECT 		cs.category_md5, cs.predicate_md5, cs.object_md5, COUNT(DISTINCT cs.subject_md5), cs.inverted
	FROM 		EVAL_NO_CLEANSING_cs_join_md5 AS cs
	LEFT JOIN	EVAL_NO_CLEANSING_subjects_per_category_count_md5 AS spc
	ON			cs.category_md5 = spc.category_md5
	WHERE		spc.subject_count >2
	GROUP BY	cs.category_md5, cs.predicate_md5, cs.object_md5;
CREATE INDEX `idx_poc_md5_category` 	ON `EVAL_NO_CLEANSING_predicate_object_count_md5`(`category_md5`);
CREATE INDEX `idx_poc_md5_count` 	ON `EVAL_NO_CLEANSING_predicate_object_count_md5`(`count`);


DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_property_probability_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_property_probability_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_property_probability_md5 
	SELECT 		poc.category_md5, poc.predicate_md5, poc.object_md5, (poc.count/spc.subject_count), poc.inverted
	FROM 		EVAL_NO_CLEANSING_predicate_object_count_md5 	AS poc
	LEFT JOIN	EVAL_NO_CLEANSING_subjects_per_category_count_md5 AS spc
	ON			poc.category_md5 = spc.category_md5;

CREATE INDEX `idx_pp_category` 	ON `EVAL_NO_CLEANSING_property_probability_md5`(`category_md5`);
CREATE INDEX `idx_pp_cpo` 	ON `EVAL_NO_CLEANSING_property_probability_md5`(`category_md5`, `predicate_md5`, `object_md5`);

#################################################################################################################################################################################

# Create suggestions

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_suggestions_md5`;
CREATE TABLE `EVAL_NO_CLEANSING_suggestions_md5` (  
	`status` 		varchar(7), 
	`subject_md5` 	CHAR(32), 
	`predicate_md5` CHAR(32), 
	`object_md5` 	CHAR(32),
	`probability`	float, 
	`category_md5`	CHAR(32),
	`inverted`		tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_suggestions_md5
	SELECT "A" AS status, ca.resource_md5 AS subject_md5, pp.predicate_md5, pp.object_md5, pp.probability, pp.category_md5, pp.inverted
    	FROM
    		(SELECT 	pp.predicate_md5, pp.object_md5, pp.probability, pp.category_md5, pp.inverted
    			FROM 	EVAL_NO_CLEANSING_property_probability_md5 AS pp
    			WHERE	pp.probability        >= 0.9
        		AND		pp.probability        < 1) AS pp
    
	JOIN 		EVAL_NO_CLEANSING_categories_md5 	AS ca 	ON pp.category_md5 	= ca.category_md5

	LEFT JOIN 	EVAL_NO_CLEANSING_cs_join_md5 	AS st 	ON st.subject_md5 	= ca.resource_md5 
										AND st.predicate_md5	= pp.predicate_md5 
										AND st.object_md5 	= pp.object_md5
    WHERE st.predicate_md5 IS NULL 
	AND st.object_md5 IS NULL;

#################################################################################################################################################################################

# Re-translate suggestions

DROP TABLE IF EXISTS `EVAL_NO_CLEANSING_suggestions_clear`;
CREATE TABLE `EVAL_NO_CLEANSING_suggestions_clear` (
	`status` 	VARCHAR(7),
	`subject` 	VARCHAR(1000),
	`predicate` VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`probability`	FLOAT,
	`category`	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO EVAL_NO_CLEANSING_suggestions_clear
	SELECT 		sug.status, s2md5.resource, p2md5.predicate, o2md5.resource, sug.probability, c2md5.category, sug.inverted
	FROM 		EVAL_NO_CLEANSING_suggestions_md5 	AS sug
	LEFT JOIN 	EVAL_NO_CLEANSING_all_rso_translation 	AS s2md5 ON sug.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	EVAL_NO_CLEANSING_predicate_translation 	AS p2md5 ON sug.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	EVAL_NO_CLEANSING_all_rso_translation 	AS o2md5 ON sug.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	EVAL_NO_CLEANSING_category_translation	AS c2md5 ON sug.category_md5 	= c2md5.category_md5;
