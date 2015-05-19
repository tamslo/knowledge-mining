import mysql.connector
from mysql.connector import errorcode
from python.Config import Config
from python.DumpConverter import DumpConverter
from python.Analyser import Analyser

# TODO add Markus' command line params

# writes dumps into csv file
converter = DumpConverter()
converter.execute("categories")
converter.execute("statements")

# establish db connection
config = Config()
mysql_init_config = config.mysql_init_config
mysql_config = config.mysql_config
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

# build statements table

# join categories and statements

# run analysis
analyser = Analyser()
analyser.execute()

# process suggestions
