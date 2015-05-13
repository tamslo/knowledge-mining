import mysql.connector
import re

from Config import Config

class DumpImporter():

    def __init__(self):
        config = Config()
        self.mysql_config = config.get_mysql_config()

    def execute(self, dump_type, dump_path):
        db_connection = mysql.connector.connect(**self.mysql_config)
        cursor = db_connection.cursor()

        dump = open(dump_path, encoding="utf8")

        for line in dump:
            if line.startswith('<'):
                entities = self.extract_entities(line)
                if dump_type == "categories":
                    self.process_category(entities, cursor)
                elif dump_type == "statements":
                    self.process_statement(entities, cursor)
            else:
                continue


    def process_category(self, entities, cursor):
        category = entities["object"]
        resource = entities["subject"]
        try:
            cursor.execute("INSERT INTO categories (category, resource) VALUES ('{0}', '{1}');".format(category, resource))
        except mysql.connector.Error as err:
            print("Failed inserting {0}, {1} into categories: {2}".format(category, resource, err))


    def process_statement(self, entities, cursor):
        subject = entities["subject"]
        predicate = entities["predicate"]
        object = entities["object"]
        try:
            cursor.execute("INSERT INTO statements (subject, predicate, object) VALUES ('{0}', '{1}', '{2}');".format(subject, predicate, object))
        except mysql.connector.Error as err:
            print("Failed inserting {0}, {1}, {2} into categories: {3}".format(subject, predicate, object, err))

    def extract_entities(self, line):
        #TODO: adapt regex for statements
        #rdf_rgx = re.compile('^<([^<]*)> <([^<]*)> <([^<]*)> \\.$')

        position = 0
        entities = { "subject": "", "predicate": "", "object": ""}
        current_entity = "subject"

        # first of all delete '/n', '.' and maybe ' '
        line = line[:-2]
        if line.endswith(' '):
            line = line[:-1]

        # TODO: escape properly
        for char in line:
            if char == ' ':
                if current_entity == "subject":
                    current_entity = "predicate"
                elif current_entity == "predicate":
                    current_entity = "object"
                else:
                    entities[current_entity] += char
                    continue
            elif char == "'":
                entities[current_entity] += "\\" + char
            else:
                entities[current_entity] += char
            position += 1
        for entity in entities:
            if entities[entity].startswith("<") and entities[entity].endswith(">"):
                entities[entity] = entities[entity][1:-1]
        return entities
