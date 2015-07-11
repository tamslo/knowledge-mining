# table with functional properties

DROP TABLE IF EXISTS `TS_TEST_functional_properties_original`;
CREATE TABLE `TS_TEST_functional_properties_original` (
  `predicate` 		varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '~/KnowMin/repo/data/func_prop.csv'
INTO TABLE TS_TEST_functional_properties_original
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
ESCAPED BY '\\'
LINES TERMINATED BY '\n';


DROP TABLE IF EXISTS `TS_TEST_functional_properties_md5`;
CREATE TABLE `TS_TEST_functional_properties_md5` (
  `predicate_md5` 		varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_functional_properties_md5
SELECT md5(predicate)
FROM TS_TEST_functional_properties_original;

# stats for usage of properties
# NOT WORKING SO FAR

-- SELECT predicate, avg
-- FROM
-- 	(SELECT predicate_md5, AVG(count) AS avg
-- 	FROM
-- 		(SELECT predicate_md5, COUNT(predicate_md5) AS count
-- 		FROM statements_md5
-- 		GROUP BY subject_md5, predicate_md5) counts
-- 	GROUP BY predicate_md5) avgs
-- INNER JOIN predicate_translation pt
-- ON avgs.predicate_md5 = pt.predicate_md5;