DROP TABLE IF EXISTS `cs_join_md5_combined`;
CREATE TABLE `cs_join_md5_combined` (
	'category_md5'	CHAR(32),
	'subject_md5'	CHAR(32),
	'predicate_md5'	CHAR(32),
	'object_md5'	CHAR(32),
	'inverted'	tinyint(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cs_join_md5_combined SELECT *,1 FROM inv_object_join_md5;
INSERT INTO cs_join_md5_combined SELECT *,0 FROM cs_join_md5;

CREATE INDEX idx_cs_join_md5_combined_category 	on cs_join_md5_combined(category_md5);
CREATE INDEX idx_cs_join_md5_combined_subject 	on cs_join_md5_combined(subject_md5);
CREATE INDEX idx_cs_join_md5_combined_cpo 	on cs_join_md5_combined(category_md5, predicate_md5, object_md5);

