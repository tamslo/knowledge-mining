DROP TABLE IF EXISTS `MK_TEST_cs_join_md5`;
CREATE TABLE `MK_TEST_cs_join_md5` (
	`category_md5`	CHAR(32),
	`subject_md5`	CHAR(32),
	`predicate_md5`	CHAR(32),
	`object_md5`	CHAR(32),
	`inverted`	tinyint(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		MK_TEST_cs_join_md5 
	SELECT		c.category_md5, st.subject_md5, st.predicate_md5, st.object_md5, FALSE 
	FROM		MK_TEST_categories_md5 AS c
	INNER JOIN 	MK_TEST_statements_md5 AS st
	ON 		c.resource_md5 = st.subject_md5;

DROP TABLE IF EXISTS `MK_TEST_cat_wo_stat_md5`;
CREATE TABLE `MK_TEST_cat_wo_stat_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
INSERT INTO 		MK_TEST_cat_wo_stat_md5 
	SELECT		c.resource_md5, c.category_md5 
	FROM		MK_TEST_categories_md5 AS c
	LEFT JOIN 	MK_TEST_statements_md5 AS st
	ON 		c.resource_md5 = st.subject_md5
	WHERE		st.subject_md5 IS NULL;

CREATE INDEX `cws_md5_resource` on `MK_TEST_cat_wo_stat_md5`(`resource_md5`);
CREATE INDEX `cws_md5_category` on `MK_TEST_cat_wo_stat_md5`(`category_md5`);

INSERT INTO 		MK_TEST_cs_join_md5 
	SELECT		cwo.category_md5, st.object_md5, st.predicate_md5, st.subject_md5, TRUE 
	FROM		MK_TEST_cat_wo_stat_md5 AS cwo
	INNER JOIN 	MK_TEST_statements_md5 AS st
	ON 		cwo.resource_md5 = st.object_md5;

CREATE INDEX `idx_cs_join_md5_category`	on `MK_TEST_cs_join_md5`(`category_md5`);
CREATE INDEX `idx_cs_join_md5_cpo` 	on `MK_TEST_cs_join_md5`(`category_md5`, `predicate_md5`, `object_md5`);
CREATE INDEX `idx_cs_join_md5_subject` 	on `MK_TEST_cs_join_md5`(`subject_md5`);
