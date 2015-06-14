DELIMITER //

DROP PROCEDURE IF EXISTS CalculateStatistics;

# creates rudimentary stats (#categories, #subjects, avg #subjects in categories)
# currently for cs_join (to be extended to all data sets)
# (also median would be nice)
CREATE PROCEDURE CalculateStatistics()
	BEGIN
		DECLARE amount_categories INT DEFAULT 0;
		DECLARE amount_subjects INT DEFAULT 0;
		DECLARE average_subjectsInCategories FLOAT 0.0;
		
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

		SELECT count(*) INTO amount_subjects
		FROM (
			SELECT DISTINCT subject
			FROM cs_join_original) dist_subs;

		SET average_subjectsInCategories = amount_subjects / amount_categories;

		INSERT INTO stats
		VALUES ("cs_join", amount_categories, amount_subjects, average_subjectsInCategories);
	END

DELIMTER ;