# table with functional properties

DROP TABLE IF EXISTS `TS_TEST_functional_properties`;
CREATE TABLE `TS_TEST_functional_properties` (
  `predicate`	varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/func_prop.csv'
INTO TABLE TS_TEST_functional_properties
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n';

DROP TABLE IF EXISTS `TS_TEST_are_properties_functional_md5`;
CREATE TABLE `TS_TEST_are_properties_functional_md5` (
  `predicate_md5`	char(32) NOT NULL,
  `is_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_are_properties_functional_md5
SELECT md5(predicate), 1
FROM TS_TEST_functional_properties;

# PROBLEM: REALLY FUNNY COUNTS OF DISTINCT PREDICATES
# SO PROBABLY NOT WORKING SO FAR

INSERT INTO TS_TEST_are_properties_functional_md5
SELECT DISTINCT predicate_md5, 0
FROM TS_TEST_statements_md5
WHERE predicate_md5
NOT IN (SELECT DISTINCT predicate_md5 FROM TS_TEST_are_properties_functional_md5);


# stats for usage of properties

DROP TABLE IF EXISTS `TS_TEST_property_stats_md5`;
CREATE TABLE `TS_TEST_property_stats_md5` (
  `predicate_md5` 	varchar(1000) NOT NULL,
  `predicate_avg`	int NOT NULL,
  'is_functional'	tinyint(1) NOT NULL 	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# !!! NOT WORKING SO FAR, IN PROGRESS !!!

INSERT INTO TS_TEST_property_stats_md5
SELECT predicate_md5, avg, is_functional
FROM
	(SELECT predicate_md5, AVG(count) AS avg
	FROM
		(SELECT predicate_md5, COUNT(predicate_md5) AS count
		FROM statements_md5
		GROUP BY subject_md5, predicate_md5) counts
	GROUP BY predicate_md5) avgs
	INNER JOIN TS_TEST_are_properties_functional_md5 fp
	ON avgs.predicate_md5 = fp.predicate_md5;




# translate functional props table for testing

DROP TABLE IF EXISTS `TS_TEST_are_properties_functional_clear`;
CREATE TABLE `TS_TEST_are_properties_functional_clear` (
  `predicate`		varchar(1000) NOT NULL,
  `is_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_are_properties_functional_clear
SELECT trans.predicate, is_functional
FROM TS_TEST_are_properties_functional_md5 md5
INNER JOIN predicate_translation trans
ON md5.predicate_md5 = trans.predicate_md5;
