DROP TABLE IF EXISTS `subjects_per_category_count_md5`;
CREATE TABLE `subjects_per_category_count_md5`(
	`category_md5` 	CHAR(32),
	`subject_count`	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO subjects_per_category_count_md5 
	SELECT 		distinct category_md5, COUNT(distinct resource_md5) 
	FROM 		categories_md5 
	GROUP BY 	category_md5; 
CREATE INDEX `idx_spc_category` ON `subjects_per_category_count_md5`(`category_md5`);



DROP TABLE IF EXISTS `predicate_object_count_md5`;
CREATE TABLE `predicate_object_count_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`count`		INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO predicate_object_count_md5
	SELECT 		cs.category_md5, cs.predicate_md5, cs.object_md5, COUNT(DISTINCT cs.subject_md5)
	FROM 		cs_join_md5 AS cs
	LEFT JOIN	subjects_per_category_count_md5 AS spc
	ON		cs.category_md5 = spc.category_md5
	WHERE		spc.subject_count >2
	GROUP BY	cs.category_md5, cs.predicate_md5, cs.object_md5;
CREATE INDEX `idx_poc_md5_category` ON `predicate_object_count_md5`(`category_md5`);
CREATE INDEX `idx_poc_md5_count` ON `predicate_object_count_md5`(`count`);


DROP TABLE IF EXISTS `property_probability_md5`;
CREATE TABLE `property_probability_md5`(
	`category_md5`	CHAR(32) NOT NULL,
	`predicate_md5`	CHAR(32) NOT NULL,
	`object_md5`	CHAR(32) NOT NULL,
	`probability`	float NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO property_probability_md5 
	SELECT 		poc.category_md5, poc.predicate_md5, poc.object_md5, (poc.count/spc.subject_count)
	FROM 		predicate_object_count_md5 	AS poc
	LEFT JOIN	subjects_per_category_count_md5 AS spc
	ON		poc.category_md5 = spc.category_md5;

CREATE INDEX `idx_pp_category` ON `property_probability_md5`(`category_md5`);
CREATE INDEX `idx_pp_cpo` ON `property_probability_md5`(`category_md5`, `predicate_md5`, `object_md5`);

	


