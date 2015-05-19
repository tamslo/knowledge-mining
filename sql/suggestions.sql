DROP TABLE IF EXISTS suggestions;

CREATE TABLE suggestions (
	status VARCHAR(7),
	subject VARCHAR(127),
	predicate VARCHAR(127),
	object VARCHAR(127),
	probability FLOAT) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--TODO