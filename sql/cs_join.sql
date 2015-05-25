DROP TABLE IF EXISTS cs_join;

CREATE TABLE cs_join (
	category BINARY(16),
	subject BINARY(16),
	predicate BINARY(16),
	object BINARY(16)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO cs_join (
	SELECT c.category, s.subject, s.predicate, s.object
	FROM categories AS c, statements AS s
	WHERE c.resource = s.subject
	ORDER BY category);