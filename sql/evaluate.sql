DROP TABLE IF EXISTS `suggestions_md5`;
CREATE TABLE `suggestions_md5` (  
	`status` 	varchar(7), 
	`subject_md5` 	CHAR(32), 
	`predicate_md5` CHAR(32), 
	`object_md5` 	CHAR(32),
	`probability`	float, 
	`category_md5`	CHAR(32),
	`inverted`	tinyint(1)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;



INSERT INTO suggestions_md5
	SELECT 		"A", cs.subject_md5, cs.predicate_md5, cs.object_md5, pp.probability, cs.category_md5, cs.inverted
	FROM		cs_join_md5 AS cs
	LEFT JOIN	subjects_per_category_count_md5 AS spc	ON cs.category_md5 = spc.category_md5
	LEFT JOIN	property_probability_md5	AS pp	ON cs.category_md5 = pp.category_md5
	WHERE		cs.predicate_md5	!= pp.predicate_md5
	AND		cs.object_md5		!= pp.object_md5
	AND		spc.subject_count	>= 20
	AND		pp.probability		>= 0.97
	AND		pp.probability		< 1;









#		IF probability >= accept_threshold THEN 
#			INSERT INTO suggestions_md5 VALUES('A', subject_wpo_md5, c_predicate_md5, c_object_md5, probability, c_category_md5); 
#		ELSEIF probability >= review_threshold THEN 
#			INSERT INTO suggestions_md5 VALUES ('R', subject_wpo_md5, c_predicate_md5, c_object_md5, probability, c_category_md5); 
#		END IF; 
#
#
#
#		#############################################################################
#		IF total_subjects_of_category < 50 OR total_subjects_of_category > 100 THEN
#			ITERATE foreach_category_loop;
#		END IF;
#
#		IF test_counter = 100 THEN 
#			CLOSE distinct_category_cursor; 
#			LEAVE foreach_category_loop; 
#		END IF; 
#		
#		SET test_counter = test_counter +1;
#		INSERT INTO crc_md5 VALUES(c_category_md5, total_subjects_of_category);
#		##############################################################################
#
#
#		#IF total_subjects_of_category < 3 THEN
#		#	ITERATE foreach_category_loop;
#		#END IF;
#
#
#		
#		#variable thresholds
#		IF total_subjects_of_category = 3 THEN
#			SET accept_threshold	= 0.6;		
#			SET review_threshold	= 0.6;
#		ELSEIF total_subjects_of_category = 4 THEN
#			SET accept_threshold	= 0.75;		
#			SET review_threshold	= 0.75;
#		ELSEIF total_subjects_of_category = 5 THEN
#			SET accept_threshold	= 0.8;		
#			SET review_threshold	= 0.8;
#		ELSEIF total_subjects_of_category = 6 THEN
#			SET accept_threshold	= 0.83;		
#			SET review_threshold	= 0.83;
#		ELSEIF total_subjects_of_category = 7 THEN
#			SET accept_threshold	= 0.85;		
#			SET review_threshold	= 0.85;
#		ELSEIF total_subjects_of_category = 8 THEN
#			SET accept_threshold	= 0.87;		
#			SET review_threshold	= 0.87;
#		ELSEIF total_subjects_of_category = 9 THEN
#			SET accept_threshold	= 0.88;		
#			SET review_threshold	= 0.88;
#		ELSEIF total_subjects_of_category > 10 AND total_subjects_of_category < 20 THEN
#			SET accept_threshold	= 0.9;		
#			SET review_threshold	= 0.8;
#		##########################################
#		ELSEIF total_subjects_of_category > 20 THEN
#			SET accept_threshold	= 0.97;		
#			SET review_threshold	= 0.9;	
#		END IF;
#		############################################
