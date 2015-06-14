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

		DROP TABLE IF EXISTS `knowmin_1000..cs_join_md5`;
		CREATE TABLE `knowmin_1000..cs_join_md5` (
			category CHAR(32),
			subject CHAR(32),
			predicate CHAR(32),
			object CHAR(32)
			);

		SELECT count(DISTINCT category) INTO amount_categories
			FROM cs_join_original;
		
		SET every = amount_categories / 1000;

		INSERT INTO `knowmin_1000..cs_join_md5`
		SELECT category, subject, predicate, object
		FROM (
			SELECT category, resource
			FROM (
				SELECT @row := @row +1 AS rownum, category, resource
	      FROM (
	        SELECT @row := 0) r, 
	        (SELECT DISTINCT category, resource
	          FROM categories_to_md5) cats
				) ranked
			WHERE ranked.rownum % every = 0) categories
		INNER JOIN statements_to_md5
		ON statements_to_md5.subject = categories.resource;

	END //

DELIMITER ;