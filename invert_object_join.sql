DROP TABLE IF EXISTS `cat_wo_stat`;
CREATE TABLE `cat_wo_stat` (
  `resource` char(32) NOT NULL,
  `category` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

### LEFT JOIN-> we want those who have no statement match 
INSERT INTO 		cat_wo_stat 
	SELECT		c.resource, c.category 
	FROM		categories_md5 AS c
	LEFT JOIN 	statements_md5 AS st
	ON 		c.resource = st.subject
	WHERE		st.subject IS NULL;

CREATE INDEX cws_resource on cat_wo_stat(resource);
CREATE INDEX cws_category on cat_wo_stat(category);








### cleartext version for understanding
DROP TABLE IF EXISTS `cat_wo_stat_clear`;
CREATE TABLE `cat_wo_stat_clear` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cat_wo_stat_clear 
	SELECT r2md5.resource, c2md5.category
	FROM	cat_wo_stat AS cws
	LEFT JOIN resource_to_md5 AS r2md5 ON cws.resource = r2md5.resource_md5
	LEFT JOIN category_to_md5 AS c2md5 ON cws.category = c2md5.category_md5;








### and join those with statements on object (-> insert object as subject and otherwise == inverse)
DROP TABLE IF EXISTS `inv_object_join_md5`;

CREATE TABLE `inv_object_join_md5` (
	category	CHAR(32),
	subject		CHAR(32),
	predicate	CHAR(32),
	object		CHAR(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		inv_object_join_md5 
	SELECT		c.category, st.object, st.predicate, st.subject 
	FROM		cat_wo_stat AS c
	INNER JOIN 	statements_md5 AS st
	ON 		c.resource = st.object;

CREATE INDEX idx_inv_obj_join_md5_category 	on inv_object_join_md5(category);
CREATE INDEX idx_inv_obj_join_md5_cpo 		on inv_object_join_md5(category, predicate, object);
CREATE INDEX idx_inv_obj_join_md5_subject 	on inv_object_join_md5(subject);
