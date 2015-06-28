# Some basic parameter tuning
SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;


# Tables to import data
DROP TABLE IF EXISTS `categories_original`;
CREATE TABLE `categories_original` (
  `resource` varchar(1000) NOT NULL,
  `category` varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `statements_original`;
CREATE TABLE `statements_original` (
  `subject` 	varchar(1000) NOT NULL,
  `predicate` 	varchar(1000) NOT NULL,
  `object` 	varchar(1000) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;


#LOAD DATA LOCAL INFILE "categories_csv_file_path" INTO TABLE categories_original FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
#LOAD DATA LOCAL INFILE "statements_csv_file_path" INTO TABLE statements_original FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\'' ESCAPED BY '\\' LINES TERMINATED BY '\n';
