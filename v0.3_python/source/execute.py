#!/usr/bin/python

import mysql.connector
from mysql.connector import errorcode

from DumpImporter import DumpImporter
from Evaluator import Evaluator
from Config import Config

config = Config()

CATEGORIES_DUMP_PATH = config.get_categories_dump_path()
STATEMENTS_DUMP_PATH = config.get_statements_dump_path()

MYSQL_CONFIG = config.get_mysql_config()

MYSQL_INIT_CONFIG = config.get_mysql_init_config()

# if the database knowmin doesn't exist, create it
# otherwise just establish the connection

print("Setting everything up ...")

try:
    db_connection = mysql.connector.connect(**MYSQL_INIT_CONFIG)
    cursor = db_connection.cursor()
    cursor.execute("CREATE DATABASE knowmin DEFAULT CHARACTER SET 'utf8';")
except:
    pass

db_connection = mysql.connector.connect(**MYSQL_CONFIG)
cursor = db_connection.cursor(buffered = True, dictionary = True)

# drop all tables that we want to use might already exist

cursor.execute("DROP TABLE IF EXISTS categories")
cursor.execute("DROP TABLE IF EXISTS statements")
cursor.execute("DROP TABLE IF EXISTS cs_join")
cursor.execute("DROP TABLE IF EXISTS suggestions")

# create tables

try:
    cursor.execute("CREATE TABLE categories (category VARCHAR(127), resource VARCHAR(127))")
    cursor.execute("CREATE TABLE statements (subject VARCHAR(127), predicate VARCHAR(127), object VARCHAR(127))")
    cursor.execute("CREATE TABLE cs_join (category VARCHAR(127), subject VARCHAR(127), predicate VARCHAR(127), object VARCHAR(127))")
    cursor.execute("CREATE TABLE suggestions (status VARCHAR(7), subject VARCHAR(127), predicate VARCHAR(127), object VARCHAR(127), probability FLOAT)")
except mysql.connector.Error as err:
  print("Failed creating table: {}".format(err))

# import dumps

dump_importer = DumpImporter(cursor)

print("Importing categories dump ...")
dump_importer.execute("categories", CATEGORIES_DUMP_PATH)

print("Importing statements dump ...")
dump_importer.execute("statements", STATEMENTS_DUMP_PATH)

# join categories and statements table

print("Joining categories and statements ...")

try:
    cursor.execute("INSERT INTO cs_join (category, subject, predicate, object) (SELECT c.category, s.subject, s.predicate, s.object FROM categories AS c, statements AS s WHERE c.resource = s.subject ORDER BY category);")
except mysql.connector.Error as err:
    print("Failed joining categories and statements: {}".format(err))

# run evaluation

print("Evaluating ...")

another_cursor = db_connection.cursor(dictionary = True)

evaluator = Evaluator(cursor, another_cursor)
evaluator.execute()

print("Done.")

db_connection.close()
