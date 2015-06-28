DROP TABLE IF EXISTS 'property_count';

CREATE TABLE 'property_count'(
	`category`	char(32) NOT NULL,
	'predicate'	char(32) NOT NULL,
	'object'	char(32) NOT NULL,
	'probability'	float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO property_count

	SELECT cc.category, cc.predicate, cc.object, count(distinct cc.subject) 

	FROM 		cs_join_md5_combined AS cc
	LEFT JOIN	subjects_per_category_count_md5 AS spc
	ON		cc.category = spc.category
	WHERE		spc.resource_count > 2





INSERT INTO category_predicate_object_percentage 

		SELECT types.type, res.predicate, 0, COUNT(subject)/(
									SELECT COUNT(subject) 
									FROM prefix_dbpedia_properties_md5 AS resinner 
									WHERE res.predicate = resinner.predicate)
		FROM
			prefix_dbpedia_properties_md5 	AS res,
			prefix_dbpedia_types_md5 	AS types
		WHERE
			res.subject = types.resource
		GROUP BY 
			res.predicate,types.type;
