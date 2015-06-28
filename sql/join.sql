DROP TABLE IF EXISTS `cs_join_md5`;

CREATE TABLE `cs_join_md5` (
	category_md5	CHAR(32),
	subject_md5	CHAR(32),
	predicate_md5	CHAR(32),
	object_md5	CHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		cs_join_md5 
	SELECT		c.category_md5, st.subject_md5, st.predicate_md5, st.object_md5 
	FROM		categories_md5 AS c
	INNER JOIN 	statements_md5 AS st
	ON 		c.resource_md5 = st.subject_md5;

CREATE INDEX idx_cs_join_md5_category on cs_join_md5(category_md5);
CREATE INDEX idx_cs_join_md5_cpo on cs_join_md5(category_md5, predicate_md5, object_md5);
CREATE INDEX idx_cs_join_md5_subject on cs_join_md5(subject_md5);
