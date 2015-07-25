DELIMITER //

DROP PROCEDURE IF EXISTS test;

CREATE PROCEDURE test()
BEGIN
	DECLARE amount_categories INT DEFAULT 0;
	DECLARE amount_subjects INT DEFAULT 0;
	DECLARE average_subjectsInCategory FLOAT DEFAULT 0;

	DROP TABLE IF EXISTS stats;
	CREATE TABLE stats (
		dataset_table VARCHAR(60),
		a_categories int,
		a_subjects int,
		avg_subjectsInCategories int);

	SELECT count(*) INTO amount_categories
	FROM (
		SELECT DISTINCT category
		FROM cs_join_original) dist_cats;

	SELECT amount_categories;
END //

DELIMITER ;