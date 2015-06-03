import csv
import os
import re
import sys
from datetime import datetime


class DumpConverter():
    CSV_PATH = "csv/"
    CATEGORIES_CSV_FILE_PATH = CSV_PATH + "categories.csv"
    STATEMENTS_CSV_FILE_PATH = CSV_PATH + "statements.csv"

    TOTAL_LINES_CATEGORIES = 18731755
    TOTAL_LINES_STATEMENTS = 33449632

    CATEGORIES_DUMP_PATH = "dumps/article_categories_en.ttl"
    STATEMENTS_DUMP_PATH = "dumps/mappingbased_properties_en.ttl"

    # testdata
    # TOTAL_LINES_CATEGORIES = 1000
    # TOTAL_LINES_STATEMENTS = 1000

    # CATEGORIES_DUMP_PATH = "dumps/article_categories_1000"
    # STATEMENTS_DUMP_PATH = "dumps/mappingbased_properties_1000"
    # end of testdata

    CATEGORIES = "categories"
    STATEMENTS = "statements"

    triple_rgx = re.compile(
        r"\s*" +
        r"(?P<subject>[^\s]*)\s*" +
        r"(?P<predicate>[^\s]*)\s*" +
        r"(?P<object>[^\s]*)\s*\."
    )

    def __init__(self):
        if not os.path.exists(self.CSV_PATH):
            os.makedirs(self.CSV_PATH)
        if os.path.exists(self.CATEGORIES_CSV_FILE_PATH):
            os.remove(self.CATEGORIES_CSV_FILE_PATH)
        if os.path.exists(self.STATEMENTS_CSV_FILE_PATH):
            os.remove(self.STATEMENTS_CSV_FILE_PATH)

    def convert_categories(self):
        self.execute(self.CATEGORIES)

    def convert_statements(self):
        self.execute(self.STATEMENTS)

    def execute(self, type):
        start_time = datetime.now()
        if type == self.CATEGORIES:
            dump_path = self.CATEGORIES_DUMP_PATH
            csv_file_path = self.CATEGORIES_CSV_FILE_PATH
        elif type == self.STATEMENTS:
            dump_path = self.STATEMENTS_DUMP_PATH
            csv_file_path = self.STATEMENTS_CSV_FILE_PATH

        dump = open(dump_path, encoding="utf8")
        csv_file = open(csv_file_path, "w", encoding="utf8")

        print("Building CSV file for {} ...".format(type))
        self.convert_dump(dump, csv_file, type)
        end_time = datetime.now()
        duration = end_time - start_time
        print(" Duration {}".format(duration))

    def convert_dump(self, dump, csv_file, type):
        csv_writer = csv.writer(csv_file, lineterminator='\n')
        current_line = 0
        message = " Line"
        for line in dump:
            current_line += 1
            # delete leading and trailing whitespace
            line = line.strip()
            if line:
                entities = self.extract_entities(line)
                if entities:
                    if type == self.CATEGORIES:
                        row = self.get_category_values(entities)
                        self.show_progress(message, current_line, self.TOTAL_LINES_CATEGORIES)
                    elif type == self.STATEMENTS:
                        row = entities
                        self.show_progress(message, current_line, self.TOTAL_LINES_STATEMENTS)
                    csv_writer.writerow(row)

    def get_category_values(self, entities):
        category = entities[2]
        resource = entities[0]
        return (category, resource)

    def get_statement_values(self, entities):
        subject = entities[0]
        predicate = entities[1]
        object = entities[2]
        return (subject, predicate, object)

    def extract_entities(self, line):
        # apply regex to line
        rdf_match = self.triple_rgx.match(line)
        if rdf_match:
            subject = rdf_match.group("subject")
            predicate = rdf_match.group("predicate")
            object = rdf_match.group("object")
            return (subject, predicate, object)
        else:
            print("\n DumpConverter.extract_entities: WARNING: could not match line", line, "with rdf triple regex\n")
            return ()

    def show_progress(self, message, current, total):
        progress = float(current) / float(total) * 100
        current = str(current)
        total = str(total)
        if current == total:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)\n") % progress)
        else:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)") % progress)


converter = DumpConverter()
converter.convert_categories()
converter.convert_statements()
