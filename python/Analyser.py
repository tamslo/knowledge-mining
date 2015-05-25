import python.utils as utils
import mysql.connector

class Analyser():

    def __init__(self, cursor, another_cursor):
        self.cursor = cursor
        self.another_cursor = another_cursor

    def execute(self):
        result_file = open("results/analysis_result.txt", "w", encoding="utf8")
        categories = self.get_categories()
        categories_count = len(categories)
        result_file.write("# categories\n")
        result_file.write(str(categories_count) + "\n\n")
        result_file.write("# category\n")
        result_file.write("\t# subjects\n")
        result_file.write("\t# predicate, object pairs\n")
        for category in categories:
            self.analyse_category(category, result_file)


    def get_categories(self):
        categories = []
        try:
            self.cursor.execute("SELECT DISTINCT category FROM cs_join")
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))
        for row in self.cursor:
            categories.append(utils.mysql_hexlify(row["category"]))
        return categories

    def analyse_category(self, category, result_file):
        result_file.write(category + "\n")

        # get number of distinct subjects in category
        try:
            query = "SELECT COUNT(DISTINCT subject) AS count FROM cs_join WHERE category = (%s)"
            self.cursor.execute(query, (category,))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))
        subjects = 0
        for row in self.cursor:
            subjects = row["count"]
        result_file.write("\t" + str(subjects) + "\n")

        # get distinct pairs of predicates and objects
        try:
            query = "SELECT DISTINCT predicate, object AS count FROM cs_join WHERE category = (%s)"
            self.cursor.execute(query, (category,))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))
        predicates_objects = 0
        for row in self.cursor:
            predicates_objects += 1
        result_file.write("\t" + str(predicates_objects) + "\n")