# Some transformations to allow better indexing - everything is converted to md5 with lookup tables
DROP TABLE IF EXISTS `categories_md5`;
CREATE TABLE `categories_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `statements_md5`;
CREATE TABLE `statements_md5` (
  `subject_md5`		char(32) NOT NULL,
  `predicate_md5`	char(32) NOT NULL,
  `object_md5`		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO categories_md5 SELECT md5(resource),md5(category) FROM  categories_original;

ALTER TABLE `categories_md5` 
ADD INDEX `idx_categories_resource` (`resource_md5` ASC),
ADD INDEX `idx_categories_category` (`category_md5` ASC);

INSERT INTO statements_md5 SELECT md5(subject), md5(predicate), md5(object) FROM statements_original;

ALTER TABLE `statements_md5` 
ADD INDEX `idx_statements_subject` 	(`subject_md5` ASC),
ADD INDEX `idx_statements_predicate` 	(`predicate_md5` ASC),
ADD INDEX `idx_statements_object` 	(`object_md5` ASC);

# TRANSLATION TABLES
DROP TABLE IF EXISTS `category_translation`;
CREATE TABLE `category_translation` (
  `category` 		varchar(1000) NOT NULL,
  `category_md5` 	char(32) NOT NULL,
  PRIMARY KEY 		(`category_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO category_translation SELECT category,md5(category) FROM categories_original;

DROP TABLE IF EXISTS `resource_translation`;
CREATE TABLE `resource_translation` (
  `resource` 		varchar(1000) NOT NULL,
  `resource_md5` 	char(32) NOT NULL,
  PRIMARY KEY 		(`resource_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO resource_translation SELECT resource,md5(resource) FROM categories_original;

DROP TABLE IF EXISTS `subject_translation`;
CREATE TABLE `subject_translation` (
  `subject` 		varchar(1000) NOT NULL,
  `subject_md5` 	char(32) NOT NULL,
  PRIMARY KEY 		(`subject_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO subject_translation SELECT subject,md5(subject) FROM statements_original;

DROP TABLE IF EXISTS `object_translation`;
CREATE TABLE `object_translation` (
  `object` 		varchar(1000) NOT NULL,
  `object_md5` 		char(32) NOT NULL,
  PRIMARY KEY 		(`object_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO object_translation SELECT object,md5(object) FROM statements_original;

DROP TABLE IF EXISTS `predicate_translation`;
CREATE TABLE `predicate_translation` (
  `predicate` 		varchar(1000) NOT NULL,
  `predicate_md5` 	char(32) NOT NULL,
  PRIMARY KEY 		(`predicate_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO predicate_translation SELECT predicate,md5(predicate) FROM statements_original;
