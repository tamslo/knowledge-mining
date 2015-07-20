#!/bin/bash

if [ ! -d data ]; then
	mkdir data;
fi

echo 'Downloading article_categories_en ...'
curl -# http://downloads.dbpedia.org/2014/en/article_categories_en.ttl.bz2 | bzip2 -d > data/article_categories_en

echo 'Writing CSV file for article_categories_en ...'
cat data/article_categories_en | grep -Ev '^#' | sed "s/'/\\\'/g;s/^</'/g;s/> <.*> </','/g;s/> ./'/g" > data/categories.csv


echo 'Downloading mappingbased_properties_en ...'
curl -# http://downloads.dbpedia.org/2014/en/mappingbased_properties_en.ttl.bz2 | bzip2 -d > data/mappingbased_properties_en

echo 'Writing CSV file for mappingbased_properties_en. This will take a while ...'
cat data/mappingbased_properties_en | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 !~ /".*"\^\^<.*/' > data/statements.csv
cat data/mappingbased_properties_en | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 ~ /".*"\^\^<.*/' | sed "s/'$/>'/g;" >> data/statements.csv


echo 'Downloading redirects_en ...'
curl -# http://downloads.dbpedia.org/2014/en/redirects_en.ttl.bz2 | bzip2 -d > data/redirects_en

echo 'Writing CSV file for redirects_en ...'
cat data/redirects_en | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> <.*> </','/g;s/> ./'/g" > redirects.csv


echo 'Downloading CSV file for functional properties ...'
curl -# 'http://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=select+%3Fp+where+%7B%3Fp+a+%3Chttp%3A%2F%2Fwww.w3.org%2F2002%2F07%2Fowl%23FunctionalProperty%3E%7D+LIMIT+100&format=text%2Fcsv&timeout=30000&debug=on' > data/func_prop.csv
sed -i 1d data/func_prop.csv