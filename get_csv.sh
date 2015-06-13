

#!/bin/bash

curl -# http://downloads.dbpedia.org/2014/en/article_categories_en.ttl.bz2 | bzip2 -d | grep -Ev '^#' | sed "s/'/\\\'/g;s/^</'/g;s/> <.*> </','/g;s/> ./'/g" > categories.csv

curl -# http://downloads.dbpedia.org/2014/en/mappingbased_properties_en.ttl.bz2 | bzip2 -d | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 !~ /".*"\^\^<.*/' > statements.csv

curl -# http://downloads.dbpedia.org/2014/en/mappingbased_properties_en.ttl.bz2 | bzip2 -d | grep -Ev '^#' | native2ascii -reverse -encoding utf8 | sed "s/'/\\\'/g;s/^</'/g;s/> </','/g;s/>*[ ]*\.$/'/g;s/> \"/','\"/g;" | awk -F, '$3 ~ /".*"\^\^<.*/' | sed "s/'$/>'/g;" >> statements.csv








