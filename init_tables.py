import mysql.connector
from mysql.connector import errorcode

import python.utils as utils
from python.DumpConverter import DumpConverter
from python.Analyser import Analyser

import python.mikconfig as mikconfig

# TODO add Markus' command line params

# establish db connection
mysql_init_config = utils.get_db_init_config()
mysql_config = utils.get_db_config()

try:
    db_connection = mysql.connector.connect(**mysql_init_config)
    cursor = db_connection.cursor()
    cursor.execute("CREATE DATABASE knowmin DEFAULT CHARACTER SET 'utf8';")
except:
    pass

db_connection = mysql.connector.connect(**mysql_config)
cursor = db_connection.cursor(buffered = True, dictionary = True)
another_cursor = db_connection.cursor(dictionary = True)

# build categories table
print("Building categories table ...")
script = open("sql/categories.sql", encoding="utf8")
queries = utils.get_queries(script)
for query in queries:
    try:
        query = query.replace("${categories_csv_path}", "\"" + mikconfig.categories_csv_path + "\"")
        cursor.execute(query)
    except mysql.connector.Error as err:
        print(err)

# build statements table
print("Building statements table ...")
script = open("sql/statements.sql", encoding="utf8")
queries = utils.get_queries(script)
for query in queries:
    try:
        query = query.replace("${statements_csv_path}", "\"" + mikconfig.statements_csv_path + "\"")
        cursor.execute(query)
    except mysql.connector.Error as err:
        print(err)

# build hashes table
print("Building hashes table ...")
script = open("sql/hashes.sql", encoding="utf8")
queries = utils.get_queries(script)
for query in queries:
    try:
        query = query.replace("${hashes_csv_path}", "\"" + mikconfig.hashes_csv_path + "\"")
        cursor.execute(query)
    except mysql.connector.Error as err:
        print(err)

# join categories and statements
print("Joining categories and statements ...")
script = open("sql/cs_join.sql", encoding="utf8")
queries = utils.get_queries(script)
for query in queries:
   try:
        cursor.execute(query)
   except mysql.connector.Error as err:
        print(err)
