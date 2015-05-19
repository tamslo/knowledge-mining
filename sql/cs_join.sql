DROP TABLE IF EXISTS cs_join;

CREATE TABLE cs_join (
	category VARCHAR(127),
	subject VARCHAR(127),
	predicate VARCHAR(127),
	object VARCHAR(127)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cs_join (
	SELECT c.category, s.subject, s.predicate, s.object
	FROM categories AS c, statements AS s
	WHERE c.resource = s.subject
	ORDER BY category);