DROP TABLE IF EXISTS `cs_join_md5`;

CREATE TABLE `cs_join_md5` (
	category	CHAR(32),
	subject		CHAR(32),
	predicate	CHAR(32),
	object		CHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		cs_join_md5 
	SELECT		c.category, st.subject, st.predicate, st.object 
	FROM		categories_md5 AS c
	INNER JOIN 	statements_md5 AS st
	ON 		c.resource = st.subject;

CREATE INDEX idx_cs_join_md5_category on cs_join_md5(category);
CREATE INDEX idx_cs_join_md5_cpo on cs_join_md5(category, predicate, object);
CREATE INDEX idx_cs_join_md5_subject on cs_join_md5(subject);