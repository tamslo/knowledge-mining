#!/bin/bash

cd $(dirname $0)

if [[ ! -f settings.sh ]] ; then
  echo "please copy settings.sh.template to settings.sh and adjust the parameters to your needs"
  exit 1
fi

source settings.sh

# write dumps to database
cat csv_to_db.sql | sed -e "s:categories_csv_file_path:\"${PWD}/dumps/categories_en${IDENTIFIER}.csv\":g;s:statements_csv_file_path:\"${PWD}/dumps/mappingbased_properties_en${IDENTIFIER}.csv\":g" | mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --database="$MYSQL_DATABASE"

# generate hashes
cat hash.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}"

## join
cat join.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}"
cat join_resources_dropped_from_categories.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}"

## evaluate
cat evaluate.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}"
