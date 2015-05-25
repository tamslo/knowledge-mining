DROP TABLE IF EXISTS suggestions;

CREATE TABLE suggestions (
	status VARCHAR(7),
	subject BINARY(16),
	predicate BINARY(16),
	object BINARY(16),
	probability FLOAT) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--TODO