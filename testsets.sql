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
		
		SELECT category
		FROM (
			SELECT
				@row := @row +1 AS rownum, category
			FROM (
				SELECT @row := 0) r, categories
			) ranked
		WHERE ranked.rownum % 10000 = 0
		LIMIT 20;
	END //

DELIMITER ;