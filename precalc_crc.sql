DROP TABLE IF EXISTS subjects_per_category_count;
CREATE TABLE subjects_per_category_count(
	category_md5 	CHAR(32),
	resource_count	INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

Drop PROCEDURE IF EXISTS calculate_spc;
Delimiter $$

CREATE PROCEDURE calculate_spc() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 			boolean DEFAULT FALSE; 
	DECLARE c_category_md5 			CHAR(32);
	DECLARE total_subjects_of_category 	INT; 
	DECLARE amount_of_all_categories	INT;
	DECLARE	counter				INT;
	DECLARE accept_threshold		DECIMAL(2,2);
	DECLARE review_threshold		DECIMAL(2,2);

	DECLARE distinct_category_cursor CURSOR FOR 	SELECT DISTINCT category 
							FROM cs_join_md5; 

	DECLARE total_subjects_cursor 	 CURSOR FOR 	SELECT COUNT(distinct subject) 
							FROM cs_join_md5 
							WHERE category = c_category_md5; 

	DECLARE total_categories_cursor  CURSOR FOR	SELECT COUNT(DISTINCT category) from cs_join_md5;


	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;

	OPEN 	total_categories_cursor;
	FETCH	total_categories_cursor INTO amount_of_all_categories;	
	CLOSE	total_categories_cursor;
	SET 	counter = 0;

	OPEN distinct_category_cursor; 
	
	foreach_category_loop:LOOP 
		
		IF counter = amount_of_all_categories THEN
			CLOSE distinct_category_cursor; 
			LEAVE foreach_category_loop; 
		END IF;
		SET counter = counter +1;

		FETCH	distinct_category_cursor INTO c_category_md5; 
		OPEN 	total_subjects_cursor; 
		FETCH 	total_subjects_cursor 	INTO total_subjects_of_category; 
		CLOSE 	total_subjects_cursor; 

		INSERT INTO subjects_per_category_count VALUES(c_category_md5, total_subjects_of_category); 
		
	END LOOP foreach_category_loop; 
END BLOCK1$$

Delimiter ;

CALL calculate_spc();
