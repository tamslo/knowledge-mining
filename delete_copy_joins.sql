

Drop PROCEDURE IF EXISTS delete_copy_joins;

Delimiter $$

CREATE PROCEDURE delete_copy_joins() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 			boolean DEFAULT FALSE; 
	DECLARE table_name 			VARCHAR(127);
 
	DECLARE all_categories			INT;
	DECLARE	counter				INT;
	
	DECLARE distinct_category_cursor CURSOR FOR 	SELECT * 
							FROM table_list;

	DECLARE all_cat_cursor		 CURSOR FOR	SELECT COUNT(*) from table_list;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;

	OPEN 	all_cat_cursor;
	FETCH	all_cat_cursor INTO all_categories;	
	CLOSE	all_cat_cursor;
	SET 	counter = 0;


	

	OPEN distinct_category_cursor; 
	
	foreach_category_loop:LOOP 
		
		#####################################################
		IF counter = all_categories THEN
			CLOSE distinct_category_cursor; 
			LEAVE foreach_category_loop; 
		END IF;
		SET counter = counter +1;

		#####################################################
		FETCH	distinct_category_cursor INTO table_name; 
		SELECT table_name;

		SET @DropTable = CONCAT('Drop Table ', table_name);
		SELECT @DropTable;
		PREPARE drop_stmt FROM @DropTable; 		
		EXECUTE drop_stmt;
		DEALLOCATE PREPARE drop_stmt;


	END LOOP foreach_category_loop; 
END BLOCK1$$

Delimiter ;
