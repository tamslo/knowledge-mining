DROP TABLE IF EXISTS raw_stats;

CREATE TABLE raw_stats (
	query CHAR(32),
	result INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

####################
SELECT COUNT(DISTINCT resource) INTO @num_resources FROM categories_md5;
INSERT INTO raw_stats VALUES ('num_resources', @num_resources);

####################
SELECT COUNT(DISTINCT category) INTO @num_categories FROM categories_md5;
INSERT INTO raw_stats VALUES ('num_categories', @num_categories);

####################
SELECT COUNT(DISTINCT subject) INTO @num_subjects FROM statements_md5;
INSERT INTO raw_stats VALUES ('num_subjects', @num_subjects);

####################
SELECT COUNT(DISTINCT predicate) INTO @num_predicates FROM statements_md5;
INSERT INTO raw_stats VALUES ('num_predicates', @num_predicates);

####################
SELECT COUNT(DISTINCT object) INTO @num_objects FROM statements_md5;
INSERT INTO raw_stats VALUES ('num_objects', @num_objects);









####################
SELECT COUNT(DISTINCT category) INTO @cats_without_stat
	FROM categories_md5
	WHERE resource NOT IN (SELECT distinct subject FROM statements_md5);
INSERT INTO raw_stats VALUES ('cats_without_stat', @cats_without_stat);








####################
SELECT COUNT(DISTINCT subject) INTO @stats_without_cat
	FROM statements_md5
	WHERE subject NOT IN (SELECT resource FROM categories_md5);
INSERT INTO raw_stats VALUES ('stats_without_cat', @stats_without_cat);

####################
SELECT AVG(subcount) INTO @avg_cats_per_subj
	FROM (SELECT COUNT(category) AS subcount
		FROM categories_md5
		GROUP BY resource) counts;
INSERT INTO raw_stats VALUES ('avg_cats_per_subj', @avg_cats_per_subj);

####################
SELECT AVG(subcount) INTO @avg_subj_per_cat
	FROM (SELECT COUNT(resource) AS subcount
		FROM categories_md5
		GROUP BY category) counts;
INSERT INTO raw_stats VALUES ('avg_subj_per_cat', @avg_subj_per_cat);

####################
SELECT AVG(subcount) INTO @avg_stats_per_subj
	FROM (SELECT COUNT(subject) AS subcount
		FROM statements_md5
		GROUP BY subject) counts;
INSERT INTO raw_stats VALUES ('avg_stats_per_subj', @avg_stats_per_subj);


####################
SELECT AVG(subcount) INTO @avg_pred_obj_per_subj
	FROM (SELECT COUNT(DISTINCT predicate, object) AS subcount
		FROM statements_md5)
		GROUP BY subject) counts;
INSERT INTO raw_stats VALUES ('avg_pred_obj_per_subj', @avg_pred_obj_per_subj);

####################
SELECT COUNT(DISTINCT category) INTO @num_categories FROM cs_join_md5;
INSERT INTO raw_stats VALUES ('num_categories_in_join', @num_categories);

####################
SELECT COUNT(DISTINCT subject) INTO @num_subjects FROM cs_join_md5;
INSERT INTO raw_stats VALUES ('num_subjects_in_join', @num_subjects);

####################
SELECT COUNT(DISTINCT predicate) INTO @num_predicates FROM cs_join_md5;
INSERT INTO raw_stats VALUES ('num_predicates_in_join', @num_predicates);

####################
SELECT COUNT(DISTINCT object) INTO @num_objects FROM cs_join_md5;
INSERT INTO raw_stats VALUES ('num_objects_in_join', @num_objects);

####################
SELECT AVG(subcount) INTO @avg_subj_per_cat_in_join
	FROM (SELECT COUNT(distinct subject) AS subcount
		FROM cs_join_md5
		GROUP BY category) counts;
INSERT INTO raw_stats VALUES ('avg_subj_per_cat_in_join', @avg_subj_per_cat_in_join);

###################
SELECT AVG(subcount) INTO @avg_stats_per_subj_in_join
	FROM (SELECT distinct subject, COUNT(distinct predicate) AS subcount
		FROM cs_join_md5
		GROUP BY subject) counts;
INSERT INTO raw_stats VALUES ('avg_stats_per_subj_in_join', @avg_stats_per_subj_in_join);

