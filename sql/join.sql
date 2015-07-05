DROP TABLE IF EXISTS `cs_join_md5`;
CREATE TABLE `cs_join_md5` (
	`category_md5`	CHAR(32),
	`subject_md5`	CHAR(32),
	`predicate_md5`	CHAR(32),
	`object_md5`	CHAR(32),
	`inverted`	tinyint(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

###########################################################################################

INSERT INTO 		cs_join_md5 
	SELECT		c.category_md5, st.subject_md5, st.predicate_md5, st.object_md5, FALSE 
	FROM		categories_md5 AS c
	INNER JOIN 	statements_md5 AS st
	ON 		c.resource_md5 = st.subject_md5;

###########################################################################################

DROP TABLE IF EXISTS `cat_wo_stat_md5`;
CREATE TABLE `cat_wo_stat_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

### LEFT JOIN-> we want those who have no statement match 
INSERT INTO 		cat_wo_stat_md5 
	SELECT		c.resource_md5, c.category_md5 
	FROM		categories_md5 AS c
	LEFT JOIN 	statements_md5 AS st
	ON 		c.resource_md5 = st.subject_md5
	WHERE		st.subject_md5 IS NULL;

CREATE INDEX cws_md5_resource on cat_wo_stat_md5(resource_md5);
CREATE INDEX cws_md5_category on cat_wo_stat_md5(category_md5);

###########################################################################################

INSERT INTO 		cs_join_md5 
	SELECT		cwo.category_md5, st.object_md5, st.predicate_md5, st.subject_md5, TRUE 
	FROM		cat_wo_stat_md5 AS cwo
	INNER JOIN 	statements_md5 AS st
	ON 		cwo.resource_md5 = st.object_md5;

###########################################################################################

CREATE INDEX idx_cs_join_md5_category on cs_join_md5(category_md5);
CREATE INDEX idx_cs_join_md5_cpo on cs_join_md5(category_md5, predicate_md5, object_md5);
CREATE INDEX idx_cs_join_md5_subject on cs_join_md5(subject_md5);
