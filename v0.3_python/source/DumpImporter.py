import mysql.connector
import re

class DumpImporter():

    def __init__(self, cursor):
        self.cursor = cursor

    def execute(self, dump_type, dump_path):
        dump = open(dump_path, encoding="utf8")

        for line in dump:
            if line.startswith('<'):
                entities = self.extract_entities(line)
                if dump_type == "categories":
                    self.process_category(entities)
                elif dump_type == "statements":
                    self.process_statement(entities)
            else:
                continue


    def process_category(self, entities):
        category = entities["object"]
        resource = entities["subject"]
        try:
            query = "INSERT INTO categories (category, resource) VALUES (%s, %s);"
            self.cursor.execute(query, (category, resource))
        except mysql.connector.Error as err:
            print("Failed inserting {0}, {1} into categories: {2}".format(category, resource, err))


    def process_statement(self, entities):
        subject = entities["subject"]
        predicate = entities["predicate"]
        object = entities["object"]
        try:
            query = "INSERT INTO statements (subject, predicate, object) VALUES (%s, %s, %s);"
            self.cursor.execute(query, (subject, predicate, object))
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

        for char in line:
            if char == ' ':
                if current_entity == "subject":
                    current_entity = "predicate"
                elif current_entity == "predicate":
                    current_entity = "object"
                else:
                    entities[current_entity] += char
                    continue
            else:
                entities[current_entity] += char
            position += 1
        for entity in entities:
            if entities[entity].startswith("<") and entities[entity].endswith(">"):
                entities[entity] = entities[entity][1:-1]
        return entities
