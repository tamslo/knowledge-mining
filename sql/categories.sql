SET max_heap_table_size = 4294967295;
SET tmp_table_size = 4294967295;
SET bulk_insert_buffer_size = 256217728;

DROP TABLE IF EXISTS categories;

CREATE TABLE categories(
    category VARCHAR(127),
    resource VARCHAR(127)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA INFILE 'C:/Users/Tamara/OneDrive/Knowledge Mining/project/results/categories.csv'
    INTO TABLE categories
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n';