#!/bin/bash

curl -# http://downloads.dbpedia.org/2014/en/article_categories_en.ttl.bz2 | bzip2 -d > article_categories_en.ttl
cat article_categories_en.ttl | grep -Ev '^#' | sed "s/'/\\\'/g;s/^</'/g;s/> <.*> </','/g;s/> ./'/g" > categories_en.csv

curl -# http://downloads.dbpedia.org/2014/en/mappingbased_properties_en.ttl.bz2 | bzip2 -d > mappingbased_properties_en.ttl
cat mappingbased_properties_en.ttl | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 !~ /".*"\^\^<.*/' > mappingbased_properties_en.csv
cat mappingbased_properties_en.ttl | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 ~ /".*"\^\^<.*/' | sed "s/'$/>'/g;" >> mappingbased_properties_en.csv
