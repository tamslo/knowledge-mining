#################################
# LOAD CSV INTO DB  #
#################################

DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS statements;

CREATE TABLE categories  ( category VARCHAR(127), resource VARCHAR(127) ) ;
CREATE TABLE statements ( subject VARCHAR(127), predicate VARCHAR(127), object VARCHAR(127) );

LOAD DATA LOCAL INFILE categories_csv_file_path INTO TABLE categories FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY "'" ESCAPED BY "'" LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE statements_csv_file_path INTO TABLE statements FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY "'" ESCAPED BY "'" LINES TERMINATED BY '\n';
