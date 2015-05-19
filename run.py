import mysql.connector
import os
import shutil
from mysql.connector import errorcode

import python.utils as utils
from python.DumpConverter import DumpConverter
from python.Analyser import Analyser

# TODO add Markus' command line params

# writes dumps into csv file
if os.path.exists("results"):
   shutil.rmtree("results")
converter = DumpConverter()
converter.execute("categories")
converter.execute("statements")

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
        cursor.execute(query)
    except mysql.connector.Error as err:
        print(err)

# build statements table
print("Building statements table ...")
script = open("sql/statements.sql", encoding="utf8")
queries = utils.get_queries(script)
for query in queries:
    try:
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

# run analysis
print("Analysing ...")
analyser = Analyser(cursor, another_cursor)
analyser.execute()

# process suggestions
