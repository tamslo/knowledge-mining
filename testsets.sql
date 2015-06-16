DELIMITER //

DROP PROCEDURE IF EXISTS CreateTestSet1000Categories;

# outputs a test of 1000 Categories, that contain at least 1 subject,
# and their subjects joined with their predicates and objects
CREATE PROCEDURE CreateTestSet1000Categories()
	BEGIN
#		SELECT * 
#		FROM (
#			SELECT * 
#			FROM categories
#			LIMIT 1000
#		) cats
#		INNER JOIN ON statements
		DECLARE amount_categories INT DEFAULT 0;
		DECLARE every INT DEFAULT 0;

		DROP TABLE IF EXISTS `cs_join_md5_1000`;
		CREATE TABLE `cs_join_md5_1000` (
			category CHAR(32),
			subject CHAR(32),
			predicate CHAR(32),
			object CHAR(32)
			);

		SELECT count(DISTINCT category) INTO amount_categories
			FROM cs_join_md5;
		
		SET every = amount_categories / 1000;

		INSERT INTO `cs_join_md5_1000`
		SELECT category, subject, predicate, object
		FROM (
			SELECT category, resource
			FROM (
				SELECT @row := @row +1 AS rownum, category, resource
	      FROM (
	        SELECT @row := 0) r, 
	        (SELECT DISTINCT category, resource
	          FROM categories_md5) cats
				) ranked
			WHERE ranked.rownum % every = 0) categories
		INNER JOIN statements_md5
		ON statements_md5.subject = categories.resource;

	END //

DELIMITER ;