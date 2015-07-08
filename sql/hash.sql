DROP TABLE IF EXISTS `MK_TEST_categories_md5`;
CREATE TABLE `MK_TEST_categories_md5` (
  `resource_md5` char(32) NOT NULL,
  `category_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_categories_md5 SELECT md5(resource),md5(category) FROM  MK_TEST_categories_original;

ALTER TABLE `MK_TEST_categories_md5` 
ADD INDEX `idx_categories_md5_resource` (`resource_md5` ASC),
ADD INDEX `idx_categories_md5_category` (`category_md5` ASC);

DROP TABLE IF EXISTS `MK_TEST_statements_md5`;
CREATE TABLE `MK_TEST_statements_md5` (
  `subject_md5`		char(32) NOT NULL,
  `predicate_md5`	char(32) NOT NULL,
  `object_md5`		char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_statements_md5 SELECT md5(subject), md5(predicate), md5(object) FROM MK_TEST_statements_original;

ALTER TABLE `MK_TEST_statements_md5` 
ADD INDEX `idx_statements_md5_subject`	(`subject_md5` ASC),
ADD INDEX `idx_statements_md5_predicate` (`predicate_md5` ASC),
ADD INDEX `idx_statements_md5_object` (`object_md5` ASC);

DROP TABLE IF EXISTS `MK_TEST_redirects_md5`;
CREATE TABLE `MK_TEST_redirects_md5` (
  `resource_md5` char(32) NOT NULL,
  `redirect_md5` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO MK_TEST_redirects_md5 SELECT md5(resource),md5(redirect) FROM  MK_TEST_redirects_original;

ALTER TABLE `MK_TEST_redirects_md5` 
ADD INDEX `idx_redirects_md5_resource` (`resource_md5` ASC),
ADD INDEX `idx_redirects_md5_redirect` (`redirect_md5` ASC);

DROP TABLE IF EXISTS `MK_TEST_category_translation`;
CREATE TABLE `MK_TEST_category_translation` (
  `category` 		varchar(1000) 	NOT NULL,
  `category_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`category_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO MK_TEST_category_translation SELECT category,md5(category) FROM MK_TEST_categories_original;

DROP TABLE IF EXISTS `MK_TEST_predicate_translation`;
CREATE TABLE `MK_TEST_predicate_translation` (
  `predicate` 		varchar(1000) 	NOT NULL,
  `predicate_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`predicate_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT IGNORE INTO MK_TEST_predicate_translation SELECT predicate,md5(predicate) FROM MK_TEST_statements_original;

DROP TABLE IF EXISTS `MK_TEST_all_rso_translation`;
CREATE TABLE `MK_TEST_all_rso_translation` (
  `resource` 		varchar(1000) 	NOT NULL,
  `resource_md5` 	char(32) 	NOT NULL,
  PRIMARY KEY 		(`resource_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO MK_TEST_all_rso_translation SELECT resource,md5(resource)	FROM MK_TEST_categories_original;
INSERT IGNORE INTO MK_TEST_all_rso_translation SELECT subject,md5(subject) 	FROM MK_TEST_statements_original;
INSERT IGNORE INTO MK_TEST_all_rso_translation SELECT object,md5(object) 	FROM MK_TEST_statements_original;
INSERT IGNORE INTO MK_TEST_all_rso_translation SELECT resource,md5(resource)  FROM MK_TEST_redirects_original;
INSERT IGNORE INTO MK_TEST_all_rso_translation SELECT redirect,md5(redirect)  FROM MK_TEST_redirects_original;