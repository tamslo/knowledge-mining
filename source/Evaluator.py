import mysql.connector
from datetime import datetime

class Evaluator():

    THRESHOLD_ADD = 0.6
    THRESHOLD_REVIEW = 0.3

    def __init__(self, cursor, another_cursor):
        self.cursor = cursor
        self.another_cursor = another_cursor

    def execute(self):
        categories = []

        try:
            self.cursor.execute("SELECT DISTINCT category FROM cs_join")
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))


        for row in self.cursor:
            category = row["category"]
            if category not in categories:
                categories.append(category)

        results = open('results' + str(datetime.now()).replace(' ', '').replace(':', '').replace('.', ''), 'w', encoding="utf8")
        results.write("Number of categories: " + str(len(categories)) + "\n")

        results.write("\nSubjects per category:\n")

        current_category = 1

        for category in categories:
            current_category += 1
            interim_result = self.get_probabilities(category, results)
            self.insert_suggestions(interim_result, category)


    def get_probabilities(self, category, results):
        probabilities = []

        # get number of distinct subjects in category
        try:
            query = "SELECT COUNT(DISTINCT subject) AS count FROM cs_join WHERE category = (%s)"
            self.cursor.execute(query, (category,))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))
        subjects = 0
        for row in self.cursor:
            subjects = row["count"]

        results.write('#' + "\t" + category + "\t" + str(subjects) + "\n")

        # get distinct pairs of predicates and objects
        try:
            query = "SELECT DISTINCT predicate, object FROM cs_join WHERE category = (%s)"
            self.cursor.execute(query, (category,))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))

        # count subjects that have the predicate object pair
        for row in self.cursor:
            predicate = row["predicate"]
            object = row["object"]
            try:
                query = "SELECT COUNT(*) AS count FROM cs_join WHERE category = (%s) AND predicate = (%s) AND object = (%s)"
                self.another_cursor.execute(query, (category, predicate, object))
            except mysql.connector.Error as err:
                print("Query failed: {}".format(err))
            concerned_subjects = 0
            for row in self.another_cursor:
                concerned_subjects = row["count"]

            # compute probability
            probability = int(concerned_subjects) / int(subjects)
            probabilities.append({"predicate": predicate, "object": object, "probability": probability})

        return probabilities

    def insert_suggestions(self, probabilities, category):
        for interim_result in probabilities:
            predicate = interim_result["predicate"]
            object = interim_result["object"]
            probability = interim_result["probability"]
            try:
                query = "SELECT subject FROM cs_join WHERE category = %s AND NOT predicate = %s AND NOT object = %s"
                self.cursor.execute(query, (category, predicate, object))
            except mysql.connector.Error as err:
                print("Query failed: {}".format(err))
            for row in self.cursor:
                subject = row["subject"]
                status = 'D'
                if probability > self.THRESHOLD_ADD:
                    status = 'A'
                elif probability > self.THRESHOLD_REVIEW:
                    status = 'R'
                try:
                    query = "INSERT INTO suggestions (status, subject, predicate, object, probability) VALUES (%s, %s, %s, %s, %s)"
                    self.another_cursor.execute(query, (status, subject, predicate, object, probability))
                except mysql.connector.Error as err:
                    print("Query failed: {}".format(err))