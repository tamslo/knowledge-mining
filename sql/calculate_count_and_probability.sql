DROP TABLE IF EXISTS `MK_TEST_subjects_per_category_count_md5`;
CREATE TABLE `MK_TEST_subjects_per_category_count_md5`(
	`category_md5` 	CHAR(32),
	`subject_count`	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_subjects_per_category_count_md5 
	SELECT 		distinct category_md5, COUNT(distinct resource_md5) 
	FROM 		MK_TEST_categories_md5 
	GROUP BY 	category_md5; 
CREATE INDEX `idx_spc_category` ON `MK_TEST_subjects_per_category_count_md5`(`category_md5`);

DROP TABLE IF EXISTS `MK_TEST_predicate_object_count_md5`;
CREATE TABLE `MK_TEST_predicate_object_count_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`count`		INT NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_predicate_object_count_md5
	SELECT 		cs.category_md5, cs.predicate_md5, cs.object_md5, COUNT(DISTINCT cs.subject_md5), cs.inverted
	FROM 		MK_TEST_cs_join_md5 AS cs
	LEFT JOIN	MK_TEST_subjects_per_category_count_md5 AS spc
	ON		cs.category_md5 = spc.category_md5
	WHERE		spc.subject_count >2
	GROUP BY	cs.category_md5, cs.predicate_md5, cs.object_md5;
CREATE INDEX `idx_poc_md5_category` 	ON `MK_TEST_predicate_object_count_md5`(`category_md5`);
CREATE INDEX `idx_poc_md5_count` 	ON `MK_TEST_predicate_object_count_md5`(`count`);


DROP TABLE IF EXISTS `MK_TEST_property_probability_md5`;
CREATE TABLE `MK_TEST_property_probability_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`probability`	float NOT NULL,
	`inverted`	TINYINT(1) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_property_probability_md5 
	SELECT 		poc.category_md5, poc.predicate_md5, poc.object_md5, (poc.count/spc.subject_count), poc.inverted
	FROM 		MK_TEST_predicate_object_count_md5 	AS poc
	LEFT JOIN	MK_TEST_subjects_per_category_count_md5 AS spc
	ON		poc.category_md5 = spc.category_md5;

CREATE INDEX `idx_pp_category` 	ON `MK_TEST_property_probability_md5`(`category_md5`);
CREATE INDEX `idx_pp_cpo` 	ON `MK_TEST_property_probability_md5`(`category_md5`, `predicate_md5`, `object_md5`);
