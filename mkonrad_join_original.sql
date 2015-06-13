
DROP TABLE IF EXISTS cas_join_original;

CREATE TABLE cs_join_original(
category	CHAR(32);
subject		CHAR(32);
predicate	CHAR(32);
object		CHAR(32);
);


INSERT INTO 	cs_join_original 
SELECT 		c.category, st.subject, st.predicate, st.object 
FROM 		categories_to_md5 AS c
FULL JOIN 	statements_to_md5 AS st
ON 		c.resource = st.subject;


CREATE INDEX idx_cs_join_original on cs_join_original(category, subject, predicate, object);
