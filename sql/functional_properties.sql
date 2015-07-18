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


INSERT INTO TS_TEST_are_properties_functional_md5
SELECT DISTINCT predicate_md5, 0
FROM predicate_translation
WHERE predicate_md5
NOT IN (SELECT DISTINCT predicate_md5 FROM TS_TEST_functional_properties_md5);


# stats for usage of properties

DROP TABLE IF EXISTS `TS_TEST_property_stats_md5`;
CREATE TABLE `TS_TEST_property_stats_md5` (
  `predicate_md5` 			varchar(1000) NOT NULL,
  `predicate_avg`			double NOT NULL,
  `is_functional`			tinyint(1) NOT NULL,
  `considered_functional`	tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_property_stats_md5
SELECT avgs.predicate_md5, avg, is_functional, 0
FROM
	(SELECT predicate_md5, AVG(count) AS avg
	FROM
		(SELECT subject_md5, predicate_md5, COUNT(predicate_md5) AS count
		FROM TS_TEST_statements_md5
		GROUP BY subject_md5, predicate_md5) counts
	GROUP BY predicate_md5) avgs
	INNER JOIN TS_TEST_are_properties_functional_md5 fp
	ON avgs.predicate_md5 = fp.predicate_md5
ORDER BY avg;

UPDATE TS_TEST_property_stats_md5
SET considered_functional = 1
WHERE is_functional = 1
OR predicate_avg = 1;
