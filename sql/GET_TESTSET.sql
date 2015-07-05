/*
		!!!!  Folgendes ist nicht das schönste oder eleganteste, aber dafür ist es simpel und funktioniert !!!!
*/


/*
 	Ziehe 10k zufällige Kategorien aus der Übersetzungstabelle 
	(Denn da sind die schon distinct und da ist auch alles in MD5 Format dabei und das beschleunigt die Sache schon ziemlich
*/
DROP TABLE IF EXISTS `MK_dist_categories_rand`;
CREATE TABLE `MK_dist_categories_rand` (
  `category` 		varchar(1000) NOT NULL,
  `category_md5` 	char(32) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_dist_categories_rand SELECT * FROM category_translation ORDER BY RAND() LIMIT 10000;
CREATE INDEX `idx_MK_dist_cat_rand` 		ON MK_dist_categories_rand(category_md5);

/*
	Kombiniere das noch mit den zugehörigen Resourcen (auf md5 Basis, da schneller und schon Indizes drauf)
*/
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

/*
	Hole die zugehörigen Statements mit den Resourcen als Subject oder als Object (getrennt, weil warum auch nicht, funktioniert jedenfalls auch so)
*/
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


INSERT INTO 		MK_statements_original_md5
	SELECT		sm.subject_md5, sm.predicate_md5, sm.object_md5 
	FROM		MK_dist_categories_original_md5 AS dcom
	INNER JOIN 	statements_md5 AS sm
	ON 		dcom.resource_md5 = sm.object_md5;

CREATE INDEX `som_subject` 	ON MK_statements_original_md5(subject_md5);
CREATE INDEX `som_predicate` 	ON MK_statements_original_md5(predicate_md5);
CREATE INDEX `som_object` 	ON MK_statements_original_md5(object_md5);

/*
	 Und alles wieder zurück in den Klartext
*/
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
	LEFT JOIN 	object_translation 			AS o2md5 ON som.object_md5 = o2md5.object_md5;

/*

Da wir vom Remote Server nicht ins CSV exportieren dürfen (Privileges), ziehen wir uns das also von unserer eigenen Komandokonsole aus:


mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' -B -e "Select * from MK_dist_categories_original" | sed "s/',/\\\',/g;s/\t/','/g;s/^/'/;s/$/'/;s/\n//g; s/''/\\\''/g; s/'_/\\\'_/g;" >test_categories.csv 

mysql --host=141.89.225.50 --port=3306 --database=knowmin --user=knowmin --password='bQRr2_#"XA3v8h-S' -B -e "Select * from MK_statements_original" | sed "s/',/\\\',/g;s/\t/','/g;s/^/'/;s/$/'/;s/\n//g; s/''/\\\''/g; s/'_/\\\'_/g;" >test_statements.csv 

(Ist nicht schön, aber funktioniert)
Bei den Categories gibs keine Fehler, bei den Statements 3. 2 sind egal, da wieder mal zu viel Text und Nummer 3 ist der Link zur Website von Mariyammanahalli (Gesundheit!) die da doch tatsächlich lautet: http://'/
Das ist nicht unser Fehler, das steht so auch in Wikipedia drin.


!!!!!!!!!!!!! WICHTIG!!!!!!!!
sed -i 1d test_categories.csv
sed -i 1d test_statements.csv
-> entfernt die erste Zeile aus den Files, denn da stehen die Spaltennamen drin udn die brauchen wir nicht

*/






