DROP TABLE IF EXISTS `TS_TEST_property_stats_outlier_properties`;
CREATE TABLE `TS_TEST_property_stats_outlier_properties` (
  `predicate`	 			varchar(1000) NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# LIMIT '22': SELECT 0.02 * (SELECT count(*) FROM TS_TEST_property_stats_md5 WHERE predicate_avg > 1);

INSERT INTO TS_TEST_property_stats_outlier_properties
SELECT predicate
FROM TS_TEST_property_stats_clear
WHERE predicate_avg > 1
AND is_functional = 0
ORDER BY predicate_avg
LIMIT 22;

DROP TABLE IF EXISTS `TS_TEST_property_stats_outlier_raw`;
CREATE TABLE `TS_TEST_property_stats_outlier_raw` (
  `predicate`	 			varchar(1000) NOT NULL,
  `subject`					varchar(1000) NOT NULL,
  `predicate_count`			int NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_property_stats_outlier_raw
SELECT predicate, subject, count(predicate)
FROM TS_TEST_statements_original
WHERE predicate IN (SELECT predicate FROM TS_TEST_property_stats_outlier_properties)
GROUP BY subject, predicate
ORDER BY predicate;

DROP TABLE IF EXISTS `TS_TEST_property_stats_outlier_counts`;
CREATE TABLE `TS_TEST_property_stats_outlier_counts` (
  `predicate`	 			varchar(1000) NOT NULL,
  `count_of`				int NOT NULL,
  `count`					int NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO TS_TEST_property_stats_outlier_counts
SELECT predicate, predicate_count, count(predicate_count)
FROM TS_TEST_property_stats_outlier_raw
GROUP BY predicate, predicate_count;