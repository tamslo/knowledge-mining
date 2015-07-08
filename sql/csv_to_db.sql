# Some basic parameter tuning
SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;

# Tables to import data
DROP TABLE IF EXISTS `MK_TEST_categories_original`;
CREATE TABLE `MK_TEST_categories_original` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `MK_TEST_statements_original`;
CREATE TABLE `MK_TEST_statements_original` (
  `subject` 	varchar(1000) NOT NULL,
  `predicate` 	varchar(1000) NOT NULL,
  `object` 	varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `MK_TEST_redirects_original`;
CREATE TABLE `MK_TEST_redirects_original` (
  `resource` varchar(1000) NOT NULL,
  `redirect` varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '~/Desktop/knowmin/KnowMin-MIK/sql/test_categories.csv' INTO TABLE MK_TEST_categories_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '~/Desktop/knowmin/KnowMin-MIK/sql/test_statements.csv' INTO TABLE MK_TEST_statements_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '~/Desktop/knowmin/KnowMin-MIK/sql/redirects.csv' INTO TABLE MK_TEST_redirects_original FIELDS TERMINATED BY ',' ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
