DELIMITER //

DROP PROCEDURE IF EXISTS CalculateStatistics;

# creates rudimentary stats (#categories, #subjects, avg #subjects in categories)
# currently for cs_join (to be extended to all data sets)
# (also median would be nice)
CREATE PROCEDURE CalculateStatistics()
	BEGIN
		DECLARE amount_categories INT DEFAULT 0;
		DECLARE amount_subjects INT DEFAULT 0;
		DECLARE amount_predicates INT DEFAULT 0;
		DECLARE amount_objects INT DEFAULT 0;
		DECLARE average_subjectsInCategories FLOAT DEFAULT 0.0;
		DECLARE average_categoriesPerSubject FLOAT DEFAULT 0.0;
		DECLARE average_statementsPerSubject FLOAT DEFAULT 0.0;
		
		DROP TABLE IF EXISTS stats;
		CREATE TABLE stats (
			dataset_table VARCHAR(60),
			a_categories int,
			a_subjects int,
			a_predicates int,
			a_objects int,
			avg_subjectsInCategories float,
			avg_categoriesPerSubject float,
			avg_statementsPerSubject float);

		SELECT count(*) INTO amount_categories
		FROM (
			SELECT DISTINCT category
			FROM cs_join_md5) dist_cats;

		SELECT count(*) INTO amount_subjects
		FROM (
			SELECT DISTINCT subject
			FROM cs_join_md5) dist_subs;

		SELECT count(*) INTO amount_predicates
		FROM (
			SELECT DISTINCT predicate
			FROM cs_join_md5) dist_preds;

		SELECT count(*) INTO amount_objects
		FROM (
			SELECT DISTINCT object
			FROM cs_join_md5) dist_objs;

		SET average_subjectsInCategories = amount_subjects / amount_categories;
		SET average_categoriesPerSubject = amount_categories / amount_subjects;
			
		SELECT AVG(subcounts) INTO average_statementsPerSubject
		FROM (
			SELECT count(subject) AS subcounts
			FROM cs_join_md5
			GROUP BY subject) counts;


		INSERT INTO stats
		VALUES ("cs_join", amount_categories, amount_subjects, 
			amount_predicates, amount_objects, average_subjectsIncategories,
			average_categoriesPerSubject, average_subjectsInCategories);
	END //

DELIMITER ;