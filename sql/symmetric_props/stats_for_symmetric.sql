DROP TABLE IF EXISTS `PFX_symmetric_props_md5`;
CREATE TABLE `PFX_symmetric_props_md5` (
	`predicate_md5`			char(32),
	`symmetric_usage`		double,
	`considered_symmetric`	tinyint(1)
);

INSERT INTO PFX_symmetric_props_md5
SELECT symm_counts.predicate_md5, symm_count/n_symm_count, 0
FROM (	
		SELECT predicate_md5, count(*) as symm_count
		FROM statementse_md5
		WHERE EXISTS (
			SELECT *
			FROM statementse_md5 s1, statementse_md5 s2
			WHERE	s1.subject_md5 = s2.object_md5
			AND		s1.predicate_md5 = s2.predicate_md5
			AND		s1.object_md5 = s2.subject_md5)
		GROUP BY predicate_md5) as symm_counts,
	 (
	 	SELECT predicate_md5, count(*) as n_symm_count
	 	FROM statementse_md5
	 	WHERE EXISTS (
	 		SELECT *
	 		FROM statementse_md5 s1, statementse_md5 s2
			WHERE NOT	s1.subject_md5 = s2.object_md5
			AND NOT		s1.predicate_md5 = s2.predicate_md5
			AND	NOT		s1.object_md5 = s2.subject_md5)
	 	GROUP BY predicate_md5) as n_symm_counts
WHERE symm_counts.predicate_md5 = n_symm_counts.predicate_md5;

UPDATE PFX_symmetric_props_md5
SET considered_symmetric = 1
WHERE symmetric_usage >= 0.9;