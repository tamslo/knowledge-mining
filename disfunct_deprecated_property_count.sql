Drop PROCEDURE IF EXISTS evaluate;

Delimiter $$

CREATE PROCEDURE evaluate() 
BLOCK1: BEGIN 

	DECLARE no_more_rows1 			boolean DEFAULT FALSE; 
	DECLARE c_category_md5 			CHAR(32);
	DECLARE total_subjects_of_category 	INT; 
	DECLARE all_categories			INT;
	DECLARE	counter				INT;
	DECLARE	test_counter			INT;


	### Only those categories where there are more than two subjects contained
	DECLARE distinct_category_cursor CURSOR FOR 	SELECT 		DISTINCT category 
							FROM 		cs_join_md5_combined 		AS cc
							LEFT JOIN	subjects_per_category_count_md5 AS spc
							ON		cc.category = spc.category
							WHERE		spc.resource_count > 2;
 

	DECLARE all_cat_cursor		 CURSOR FOR	SELECT 		COUNT(DISTINCT category) 
							FROM 		cs_join_md5_combined 		AS cc
							LEFT JOIN	subjects_per_category_count_md5 AS spc
							ON		cc.category = spc.category
							WHERE		spc.resource_count > 2;


	DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows1 = TRUE;
	

	OPEN 	all_cat_cursor;
	FETCH	all_cat_cursor INTO all_categories;	
	CLOSE	all_cat_cursor;
	SET 	counter = 0;

	#####################
	SET test_counter = 0;
	#####################


	OPEN distinct_category_cursor; 
	
	foreach_category_loop:LOOP 
		
		IF counter = all_categories THEN
			CLOSE distinct_category_cursor; 
			LEAVE foreach_category_loop; 
		END IF;
		SET counter = counter +1;

		FETCH	distinct_category_cursor INTO c_category_md5; 
		OPEN 	total_subjects_cursor; 
		FETCH 	total_subjects_cursor 	INTO total_subjects_of_category; 
		CLOSE 	total_subjects_cursor; 


	
		#IF total_subjects_of_category < 3 THEN
		#	ITERATE foreach_category_loop;
		#END IF;




		BLOCK2: BEGIN 
			DECLARE no_more_rows2 		BOOLEAN DEFAULT FALSE; 
			DECLARE c_predicate_md5 	CHAR(32); 
			DECLARE c_object_md5 		CHAR(32); 
			DECLARE probability 		DECIMAL(2,2);
			DECLARE concerned_subjects 	INT; 
			DECLARE dist_pred_obj_cursor CURSOR FOR SELECT DISTINCT predicate, object 
								FROM cs_join_md5 
								WHERE category = c_category_md5; 

			DECLARE concerned_subj_count CURSOR FOR SELECT COUNT(distinct subject) 
								FROM cs_join_md5 
								WHERE category		= c_category_md5 
								AND predicate		= c_predicate_md5 
								AND object		= c_object_md5; 

			DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows2=TRUE; 
			
			OPEN dist_pred_obj_cursor; 
			
			pred_obj_loop:LOOP 
				
				FETCH 	dist_pred_obj_cursor INTO c_predicate_md5, c_object_md5; 
				OPEN 	concerned_subj_count; 
				FETCH 	concerned_subj_count INTO concerned_subjects; 
				CLOSE 	concerned_subj_count; 
				
				SET probability = concerned_subjects / total_subjects_of_category; 

				IF no_more_rows2 THEN 
					CLOSE dist_pred_obj_cursor; 
					LEAVE pred_obj_loop; 
				END IF; 
				

			END LOOP pred_obj_loop; 
		END BLOCK2; 
	END LOOP foreach_category_loop; 
END BLOCK1$$

Delimiter ;

CALL evaluate;
