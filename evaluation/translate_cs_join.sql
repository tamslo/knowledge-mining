DROP TABLE IF EXISTS `TS_TEST_cs_join_clear`;
CREATE TABLE `TS_TEST_cs_join_clear` (
	`category`	VARCHAR(1000),
	`subject` 	VARCHAR(1000),
	`predicate` 	VARCHAR(1000),
	`object` 	VARCHAR(1000),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO TS_TEST_cs_join_clear
	SELECT c2md5.category, s2md5.resource, p2md5.predicate, o2md5.resource, cs.inverted
	FROM 		TS_TEST_cs_join_md5 	AS cs
	LEFT JOIN 	TS_TEST_all_rso_translation 	AS s2md5 ON cs.subject_md5 	= s2md5.resource_md5	
	LEFT JOIN 	TS_TEST_predicate_translation 	AS p2md5 ON cs.predicate_md5 	= p2md5.predicate_md5 	
	LEFT JOIN 	TS_TEST_all_rso_translation 	AS o2md5 ON cs.object_md5 	= o2md5.resource_md5	
	LEFT JOIN 	TS_TEST_category_translation	AS c2md5 ON cs.category_md5 	= c2md5.category_md5;