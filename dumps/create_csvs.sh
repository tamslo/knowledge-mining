#!/bin/bash

cd $(dirname $0)

source ../settings.sh

cat article_categories_en${IDENTIFIER} | grep -Ev '^#' | sed "s/'/\\\'/g;s/^</'/g;s/> <.*> </','/g;s/> ./'/g" > categories_en${IDENTIFIER}.csv

cat mappingbased_properties_en${IDENTIFIER} | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 !~ /".*"\^\^<.*/' > mappingbased_properties_en${IDENTIFIER}.csv
cat mappingbased_properties_en${IDENTIFIER} | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 ~ /".*"\^\^<.*/' | sed "s/'$/>'/g;" >> mappingbased_properties_en${IDENTIFIER}.csv

