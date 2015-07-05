# Workflow

If you want to work on a testing dataset simply create a new database for it and adjust MYSQL_DATABASE.
The script workflow_script.sh can be used as a source for your work on the command line.

Befor you start to work copy the script settings.sh.template to settings.sh and adjust it to fit your needs.
It is recommended to ```source settings.sh``` also on your command line. This way you can simply copy single statements from workflow_script.sh without changing anything.

* dumps/get_csv.sh
  - parts can be used for custom (e.g. test) dumps
* csv_to_db.sql
* hash.sql
* join.sql
* (can be omitted) join_resources_dropped_from_categories.sql
* evaluate.sql

## Testsets

* execute testsets.sql and then manually move generated test set to other database
