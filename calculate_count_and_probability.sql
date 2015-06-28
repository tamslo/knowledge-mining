
DROP TABLE IF EXISTS 'subjects_per_category_count_md5';
CREATE TABLE 'subjects_per_category_count_md5'(
	'category' 	CHAR(32),
	'resource_count'	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO subjects_per_category_count_md5 
	SELECT category, COUNT(distinct subject) 
	FROM cs_join_md5_combined 
	GROUP BY category; 
