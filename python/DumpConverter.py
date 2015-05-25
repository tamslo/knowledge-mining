import csv
import hashlib
import os
import re
import sys
import python.utils as utils
from datetime import datetime

# writes dumps into csv output_file

class DumpConverter():

    CATEGORIES = "categories"
    STATEMENTS = "statements"

    triple_rgx = re.compile(
        r"\s*" + 
        r"(?P<subject>[^\s]*)\s*" + 
        r"(?P<predicate>[^\s]*)\s*" + 
        r"(?P<object>[^\s]*)\s*\."
        )

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
    HASHES_OUTPUT_FILE_PATH = "results/hashes.csv"

    all_hashesh = {}

    def __init__(self):
        if not os.path.exists("results"):
            os.makedirs("results")
        if os.path.exists(self.HASHES_OUTPUT_FILE_PATH):
            os.remove(self.HASHES_OUTPUT_FILE_PATH)
        if os.path.exists(self.CATEGORIES_OUTPUT_FILE_PATH):
            os.remove(self.CATEGORIES_OUTPUT_FILE_PATH)
        if os.path.exists(self.STATEMENTS_OUTPUT_FILE_PATH):
            os.remove(self.STATEMENTS_OUTPUT_FILE_PATH)

    def convert_categories(self):
        self.execute(self.CATEGORIES)

    def convert_statements(self):
        self.execute(self.STATEMENTS)

    def write_hashes(self):
        start_time = datetime.now()
        output_file = open(self.HASHES_OUTPUT_FILE_PATH, "w", encoding="utf8")
        csv_writer = csv.writer(output_file, lineterminator='\n')
        print("Building CSV output_file for hashes")

        counter = 0
        hash_count = len(self.all_hashesh)
        for entity, its_hash in self.all_hashesh.items():
            if counter % 1024 == 0:
                self.show_progress(" Hash", counter, hash_count)
            csv_writer.writerow((utils.mysql_hexlify(its_hash), entity))
            counter += 1

        end_time = datetime.now()
        duration = end_time - start_time
        print(" Duration {}".format(duration))

    def delete_hashes(self):
        self.all_hashesh = {}

    def execute(self, type):
        start_time = datetime.now()
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
        csv_writer = csv.writer(output_file, lineterminator='\n')
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
        subject = entities["subject"]
        predicate = entities["predicate"]
        object = entities["object"]
        return (subject, predicate, object)

    def extract_entities(self, line):
        # apply regex to line
        rdf_match = self.triple_rgx.match(line)
        if rdf_match:
            subject = rdf_match.group("subject")
            subject_digest = hashlib.md5(subject.encode()).digest()
            self.all_hashesh[subject] = subject_digest
            predicate = rdf_match.group("predicate")
            predicate_digest = hashlib.md5(predicate.encode()).digest()
            self.all_hashesh[predicate] = predicate_digest
            object = rdf_match.group("object")
            object_digest = hashlib.md5(object.encode()).digest()
            self.all_hashesh[object] = object_digest
            return (subject_digest, predicate_digest, object_digest)
        else:
            print("DumpConverter.extract_entities: WARNING: could not match line", line, "with rdf triple regex")
            return ()

    def show_progress(self, message, current, total):
        progress = float(current) / float(total) * 100
        current = str(current)
        total = str(total)
        if current == total:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)\n") % progress)
        else:
            sys.stdout.write(("\r" + message + " " + current + " of " + total + " (%.2f%%)") % progress)
