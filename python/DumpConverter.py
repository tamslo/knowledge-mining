import os
import sys
import csv
from datetime import datetime

# writes dumps into csv output_file

class DumpConverter():

    CATEGORIES = "categories"
    STATEMENTS = "statements"

    # TOTAL_LINES_CATEGORIES = 18731755
    # TOTAL_LINES_STATEMENTS = 33449632
    #
    # CATEGORIES_DUMP_PATH = "dumps/article_categories_en.ttl"
    # STATEMENTS_DUMP_PATH = "dumps/mappingbased_properties_en.ttl"

    # testdata
    TOTAL_LINES_CATEGORIES = 1000
    TOTAL_LINES_STATEMENTS = 1000

    CATEGORIES_DUMP_PATH = "dumps/article_categories_1000"
    STATEMENTS_DUMP_PATH = "dumps/mappingbased_properties_1000"



    CATEGORIES_OUTPUT_FILE_PATH = "results/categories.csv"
    STATEMENTS_OUTPUT_FILE_PATH = "results/statements.csv"

    def execute(self, type):
        start_time = datetime.now()
        if not os.path.exists("results"):
            os.makedirs("results")

        if type == self.CATEGORIES:
            dump_path = self.CATEGORIES_DUMP_PATH
            output_file_path = self.CATEGORIES_OUTPUT_FILE_PATH
        elif type == self.STATEMENTS:
            dump_path = self.STATEMENTS_DUMP_PATH
            output_file_path = self.STATEMENTS_OUTPUT_FILE_PATH

        dump = open(dump_path, encoding="utf8")
        output_file = open(output_file_path, "w", encoding="utf8")

        print("Building CSV output_file for {} ...".format(type))
        self.convert_dump(dump, output_file, type)
        end_time = datetime.now()
        duration = end_time - start_time
        print(" Duration {}".format(duration))



    def convert_dump(self, dump, output_file, type):
        csv_writer = csv.writer(output_file)
        current_line = 0
        message = " Line"
        for line in dump:
            current_line += 1
            if self.has_content(line):
                entities = self.extract_entities(line)
                if type == self.CATEGORIES:
                    row = self.get_category_values(entities)
                    self.show_progress(message, current_line, self.TOTAL_LINES_CATEGORIES)
                elif type == self.STATEMENTS:
                    row = self.get_statement_values(entities)
                    self.show_progress(message, current_line, self.TOTAL_LINES_STATEMENTS)
                csv_writer.writerow(row)

    def has_content(self, line):
        return line.startswith("<")

    def get_category_values(self, entities):
        category = entities["object"]
        resource = entities["subject"]
        return (category, resource)


    def get_statement_values(self, entities):
        subject = entities["subject"]
        predicate = entities["predicate"]
        object = entities["object"]
        return (subject, predicate, object)

    def extract_entities(self, line):
        entities = { "subject": "", "predicate": "", "object": ""}
        current_entity = "subject"

        # first of all delete '/n', '.' and maybe ' '
        line = line[:-2]
        if line.endswith(" "):
            line = line[:-1]

        for char in line:
            if char == " ":
                if current_entity == "subject":
                    current_entity = "predicate"
                elif current_entity == "predicate":
                    current_entity = "object"
                else:
                    entities[current_entity] += char
                    continue
            else:
                entities[current_entity] += char
        for entity in entities:
            if entities[entity].startswith("<") and entities[entity].endswith(">"):
                entities[entity] = entities[entity][1:-1]
        return entities

    def show_progress(self, message, current, total):
        progress = float(current) / float(total) * 100
        current = str(current)
        total = str(total)
        if current == total:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)\n") % progress)
        else:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)") % progress)