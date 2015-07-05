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