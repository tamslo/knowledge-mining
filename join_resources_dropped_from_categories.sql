DROP TABLE IF EXISTS `cs_join_resources_dropped_from_categories`;

CREATE TABLE `cs_join_resources_dropped_from_categories` (
  resource char(32),
  category char(32)
);

INSERT INTO `cs_join_resources_dropped_from_categories`
  SELECT * FROM `categories_to_md5` AS c WHERE c.resource NOT IN (
    SELECT subject FROM `cs_join_original`
  );
