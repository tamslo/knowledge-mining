#!/bin/bash

if [ ! -d data ]; then
	mkdir data;
fi

curl -# 'http://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=select+%3Fp+where+%7B%3Fp+a+%3Chttp%3A%2F%2Fwww.w3.org%2F2002%2F07%2Fowl%23FunctionalProperty%3E%7D+LIMIT+100&format=text%2Fcsv&timeout=30000&debug=on' > data/func_prop.csv
sed -i 1d data/func_prop.csv