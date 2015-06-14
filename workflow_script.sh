#!/bin/bash

cd $(dirname $0)

if [[ ! -f settings.sh ]] ; then
  echo "please copy settings.sh.template to settings.sh and adjust the parameters to your needs"
  exit 1
fi

source settings.sh

if [[ ! -z "${MYSQL_HOST_ARG}" ]] ; then
  echo "Refusing to run workflow script on remote server."
  echo "Please copy lines needed individually."
  exit 1
fi

# write dumps to database
echo 'Insert csv to database'
time cat csv_to_db.sql | sed -e "s:categories_csv_file_path:\"${PWD}/dumps/categories_en${IDENTIFIER}.csv\":g;s:statements_csv_file_path:\"${PWD}/dumps/mappingbased_properties_en${IDENTIFIER}.csv\":g" | mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --database="$MYSQL_DATABASE" --local-infile "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"

# generate hashes
echo
echo 'Generate hash tables of original data and translation tables'
time cat hash.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}" "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"

# create necessary
echo
echo 'Generate crc_md5/clear tables and '
time cat create_suggestion_and_crc_tables.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}" "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"

# join
echo
echo 'Execute join'
time cat join.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}" "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"

# evaluate
echo
echo 'Execute evaluation'
time cat evaluate.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}" "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"

# evaluate
echo
echo 'Retranslate crc_md5 to crc_clear and suggestions_md5 to suggestions'
time cat retranslate_crc_and_suggestions.sql | mysql --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --database="${MYSQL_DATABASE}" "${MYSQL_HOST_ARG}" "${MYSQL_PORT_ARG}"
