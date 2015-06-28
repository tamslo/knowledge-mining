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

CREATE INDEX cws_resource on cat_wo_stat(resource_md5);
CREATE INDEX cws_category on cat_wo_stat(category_md5);

### cleartext version for understanding
DROP TABLE IF EXISTS `cat_wo_stat_clear`;
CREATE TABLE `cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cat_wo_stat_clear 
	SELECT r2md5.resource, c2md5.category
	FROM	cat_wo_stat_md5	  AS cws
	LEFT JOIN resource_translation AS r2md5 ON cws.resource_md5 = r2md5.resource_md5
	LEFT JOIN category_translation AS c2md5 ON cws.category_md5 = c2md5.category_md5;

### and join those with statements on object (-> insert object as subject and otherwise == inverse)
DROP TABLE IF EXISTS `inv_object_join_md5`;
CREATE TABLE `inv_object_join_md5` (
	category_md5	CHAR(32),
	subject_md5	CHAR(32),
	predicate_md5	CHAR(32),
	object_md5	CHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		inv_object_join_md5 
	SELECT		c.category_md5, st.object_md5, st.predicate_md5, st.subject_md5 
	FROM		cat_wo_stat_md5 AS c
	INNER JOIN 	statements_md5 AS st
	ON 		c.resource_md5 = st.object_md5;

CREATE INDEX idx_inv_obj_join_md5_category 	on inv_object_join_md5(category_md5);
CREATE INDEX idx_inv_obj_join_md5_cpo 		on inv_object_join_md5(category_md5, predicate_md5, object_md5);
CREATE INDEX idx_inv_obj_join_md5_subject 	on inv_object_join_md5(subject_md5);
