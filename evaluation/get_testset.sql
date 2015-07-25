# Simple and works; tablename-prefixes may need to be adapted

# Get LIMIT x categories

DROP TABLE IF EXISTS `MK_dist_categories_rand`;
CREATE TABLE `MK_dist_categories_rand` (
  `category` 		varchar(1000) NOT NULL,
  `category_md5` 	char(32) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_dist_categories_rand SELECT * FROM category_translation ORDER BY RAND() LIMIT 5000;
CREATE INDEX `idx_MK_dist_cat_rand` 		ON MK_dist_categories_rand(category_md5);

# Get belonging resources

DROP TABLE IF EXISTS `MK_dist_categories_original_md5`;
CREATE TABLE `MK_dist_categories_original_md5` (
  `resource_md5` 		char(32) NOT NULL,
  `category_md5` 		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_dist_categories_original_md5 
	SELECT		cm.resource_md5, dcr.category_md5
	FROM		MK_dist_categories_rand AS dcr
	INNER JOIN	categories_md5 AS cm
	ON		dcr.category_md5 = cm.category_md5
	ORDER BY	dcr.category_md5;
	
CREATE INDEX `dcom_category` 	ON MK_dist_categories_original_md5(category_md5);
CREATE INDEX `dcom_resource` 	ON MK_dist_categories_original_md5(resource_md5);

# Get belonging statements

DROP TABLE IF EXISTS `MK_statements_original_md5`;
CREATE TABLE `MK_statements_original_md5` (
  `subject_md5` 	char(32) NOT NULL,
  `predicate_md5` 	char(32) NOT NULL,
  `object_md5`		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 		MK_statements_original_md5
	SELECT		sm.subject_md5, sm.predicate_md5, sm.object_md5 
	FROM		MK_dist_categories_original_md5 AS dcom
	INNER JOIN 	statements_md5 AS sm
	ON 		dcom.resource_md5 = sm.subject_md5;

INSERT INTO 	MK_statements_original_md5
	SELECT		sm.subject_md5, sm.predicate_md5, sm.object_md5 
	FROM		MK_dist_categories_original_md5 AS dcom
	INNER JOIN 	statements_md5 AS sm
	ON 			dcom.resource_md5 = sm.object_md5;

CREATE INDEX `som_subject` 	ON MK_statements_original_md5(subject_md5);
CREATE INDEX `som_predicate` 	ON MK_statements_original_md5(predicate_md5);
CREATE INDEX `som_object` 	ON MK_statements_original_md5(object_md5);


# Get belonging redirects

DROP TABLE IF EXISTS `MK_redirects_md5`;
CREATE TABLE `MK_redirects_md5` (
  `resource_md5` 		char(32) NOT NULL,
  `redirect_md5` 		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO 	MK_redirects_md5
	SELECT		rd.resource_md5, rd.redirect_md5
	FROM		MK_statements_original_md5	AS so
	INNER JOIN 	MK_TEST_redirects_md5		AS rd 
	ON 			so.subject_md5 = rd.redirect_md5
	GROUP BY	rd.resource_md5, rd.redirect_md5;

CREATE INDEX rd_resource ON MK_redirects_md5(resource_md5);
CREATE INDEX rd_redirect ON MK_redirects_md5(redirect_md5);


# Retranslate

DROP TABLE IF EXISTS `MK_dist_categories_original`;
CREATE TABLE `MK_dist_categories_original` (
  `resource` 		varchar(1000) NOT NULL,
  `category` 		varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO MK_dist_categories_original 
	SELECT 		r2md5.resource, c2md5.category
	FROM		MK_dist_categories_original_md5	  	AS dcom
	LEFT JOIN 	resource_translation 			AS r2md5 ON dcom.resource_md5 = r2md5.resource_md5
	LEFT JOIN 	category_translation 			AS c2md5 ON dcom.category_md5 = c2md5.category_md5;

DROP TABLE IF EXISTS `MK_statements_original`;
CREATE TABLE `MK_statements_original` (
  `subject` 	varchar(1000) NOT NULL,
  `predicate` 	varchar(1000) NOT NULL,
  `object`	varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_statements_original 
	SELECT 		s2md5.subject, p2md5.predicate, o2md5.object
	FROM		MK_statements_original_md5	  	AS som
	LEFT JOIN 	subject_translation 			AS s2md5 ON som.subject_md5 = s2md5.subject_md5
	LEFT JOIN 	predicate_translation 			AS p2md5 ON som.predicate_md5 = p2md5.predicate_md5
	LEFT JOIN 	object_translation 				AS o2md5 ON som.object_md5 = o2md5.object_md5;

DROP TABLE IF EXISTS `MK_redirects_original`;
CREATE TABLE `MK_redirects_original` (
  `resource` 		varchar(1000) NOT NULL,
  `redirect` 		varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_redirects_original 
	SELECT 		r2md5.resource, rd2md5.resource
	FROM		MK_redirects_md5	  			AS rd
	LEFT JOIN 	MK_TEST_all_rso_translation 	AS r2md5 ON rd.resource_md5 = r2md5.resource_md5
	LEFT JOIN 	MK_TEST_all_rso_translation 	AS rd2md5 ON rd.redirect_md5 = rd2md5.resource_md5;

/*

Workflow for getting testsets:

Run this script:
	mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' < get_testset.sql

Now get the CSV files:
	mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' -B -e "Select * from MK_dist_categories_original" | sed "s/',/\\\',/g;s/\t/','/g;s/^/'/;s/$/'/;s/\n//g; s/''/\\\''/g; s/'_/\\\'_/g;" >test_categories.csv 
	mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' -B -e "Select * from MK_statements_original" | sed "s/',/\\\',/g;s/\t/','/g;s/^/'/;s/$/'/;s/\n//g; s/''/\\\''/g; s/'_/\\\'_/g;" >test_statements.csv 
	mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' -B -e "Select * from MK_redirects_original" | sed "s/',/\\\',/g;s/\t/','/g;s/^/'/;s/$/'/;s/\n//g; s/''/\\\''/g; s/'_/\\\'_/g;" >test_redirects.csv 

	sed -i 1d test_categories.csv
	sed -i 1d test_statements.csv
	sed -i 1d test_redirects.csv

Now just adjust the paths to CSVs in the workflow script and maybe table prefixes to run it with the testset.

*/






