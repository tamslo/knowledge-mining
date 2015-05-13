import mysql.connector

from Config import Config

class Evaluator():

    THRESHOLD_ADD = 0.6
    THRESHOLD_REVIEW = 0.3

    def __init__(self):
        config = Config()
        self.mysql_config = config.get_mysql_config()

    def execute(self):
        db_connection = mysql.connector.connect(**self.mysql_config)
        cursor = db_connection.cursor(buffered = True, dictionary = True)

        categories = []

        cursor.execute("SELECT DISTINCT category FROM cs_join")

        for row in cursor:
            category = row["category"]
            if category not in categories:
                categories.append(category)

        another_cursor = db_connection.cursor(dictionary = True)

        for category in categories:
            interim_result = self.get_probabilities(cursor, another_cursor, category)
            self.insert_suggestions(cursor, another_cursor, interim_result, category)


    def get_probabilities(self, cursor, another_cursor, category):
        probabilities = []

        # get number of distinct subjects in category
        try:
            cursor.execute("SELECT COUNT(DISTINCT subject) AS count FROM cs_join WHERE category = '{}'".format(category))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))
        subjects = 0
        for row in cursor:
            subjects = row["count"]

        # get distinct pairs of predicates and objects
        try:
            cursor.execute("SELECT DISTINCT predicate, object FROM cs_join WHERE category = '{}'".format(category))
        except mysql.connector.Error as err:
            print("Query failed: {}".format(err))

        # count subjects that have the predicate object pair
        for row in cursor:
            predicate = row["predicate"]
            object = row["object"]
            try:
                another_cursor.execute("SELECT COUNT(*) AS count FROM cs_join WHERE category = '{0}' AND predicate = '{1}' AND object = '{2}'".format(category, predicate, object))
            except:
                pass
            concerned_subjects = 0
            for row in another_cursor:
                concerned_subjects = row["count"]

            # compute probability
            probability = int(concerned_subjects) / int(subjects)
            probabilities.append({"predicate": predicate, "object": object, "probability": probability})

        return probabilities

    def insert_suggestions(self, cursor, another_cursor, probabilities, category):
        for interim_result in probabilities:
            predicate = interim_result["predicate"]
            object = interim_result["object"]
            probability = interim_result["probability"]
            try:
                cursor.execute("SELECT subject FROM cs_join WHERE category = '{0}' AND NOT predicate = '{1} AND NOT object = '{2}'".format(category, predicate, object))
            except:
                pass
            for row in cursor:
                subject = row["subject"]
                status = 'D'
                if probability > self.THRESHOLD_ADD:
                    status = 'A'
                elif probability > self.THRESHOLD_REVIEW:
                    status = 'R'
                try:
                    another_cursor.execute("INSERT INTO suggestions (status, subject, predicate, object, probability) VALUES ('{0}', '{1}', '{2}', '{3}', '{4}')".format(status, subject, predicate, object, probability))
                except:
                    pass