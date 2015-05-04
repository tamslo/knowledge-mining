import os
import sys

def buildSqlHeader(script, tablename, columns, indices):
    # create table tablename with columns
    script.write('CREATE TABLE ' + tablename + ' (\n')

    currentColumn = 0
    for column in columns:
        currentColumn += 1
        if len(columns) == currentColumn:
            script.write('\t' + column + ' VARCHAR(127)\n')
        else:
            script.write('\t' + column + ' VARCHAR(127),\n')
    script.write(');\n')

    # create indices
    for indexname in indices:
        indexedColumns = ', '.join(indices[indexname])
        script.write('CREATE INDEX ' + indexname + ' ON ' + tablename + ' (' + indexedColumns + ');\n')

    # begin insert statement
    columns = ', '.join(columns)
    script.write('INSERT INTO ' + tablename + ' (' + columns + ')\n')
    script.write('VALUES')


def buildSqlBody(script, values, lastline):
    i = 0
    while i < len(values):
        if not (values[i].startswith('"') and values[i].endswith('"')):
            values[i] = values[i].replace('"', "'")
            values[i] = '"' + values[i] + '"'
        i += 1
    values = ', '.join(values)
    if lastline:
        script.write('\t(' + values + ');\n')
        script.write('\n')
    else:
        script.write('\t(' + values + '),\n')


def prepareDump(filename):
    print 'Preparing ' + filename + ' ...'
    dump = open(filename)
    totallines = sum(1 for _ in dump)
    return totallines

def isResource(entity):
    return entity.startswith('<') and entity.endswith('>')

def extractEntities(line):
    position = 0
    entities = { 'subject': '', 'predicate': '', 'object': ''}
    currentEntity = 'subject'

    # delete '/n', '.' and maybe ' '
    line = line[:-2]
    if line.endswith(' '):
        line = line[:-1]

    for char in line:
        if char == ' ':
            if currentEntity == 'subject':
                currentEntity = 'predicate'
            elif currentEntity == 'predicate':
                currentEntity = 'object'
            elif currentEntity == 'object':
                entities[currentEntity] += char
                continue
        elif char == '\n':
            break
        else:
            entities[currentEntity] += char
        position += 1
    return entities

def showProgress(current, total):
    progress = float(current) / float(total)
    sys.stdout.write("\r%.2f%%" % progress)
    sys.stdout.flush()

### ACTUAL START OF SCRIPT

if not os.path.exists('sql/'):
    os.makedirs('sql/')

## PROCESS CATEGORIES DUMP

filename = 'dumps/article_categories_en.ttl'
tablename = 'categories'
columns = ['subject', 'category']
indices = {'idx_subject_category': columns}

totallines = prepareDump(filename)

print 'Processing ' + filename + ' ...'

dump = open(filename)
sqlScript = open('sql/' + tablename + '.sql', 'w')

buildSqlHeader(sqlScript, tablename, columns, indices)

lines = 0

for line in dump:
    lines += 1
    if line.startswith('<'):
        entities = extractEntities(line)
        subject = entities['subject']
        predicate = entities['predicate']
        category = entities['object']

        lastline = False
        if lines == totallines:
            lastline = True
        values = [subject, category]

        buildSqlBody(sqlScript, values, lastline)
        showProgress(lines, totallines)

## PROCESS CATEGORIES DUMP

filename = 'dumps/mappingbased_properties_en.ttl'
tablename = 'statements'
columns = ['subject', 'predicate', 'object']
indices = {'idx_subject': ['subject'], 'idx_predicate_object': ['predicate', 'object']}

totallines = prepareDump(filename)

print 'Processing ' + filename + ' ...'

dump = open(filename)
sqlScript = open('sql/' + tablename + '.sql', 'w')

buildSqlHeader(sqlScript, tablename, columns, indices)

lines = 0

for line in dump:
    lines += 1
    if line.startswith('<'):
        entities = extractEntities(line)
        subject = entities['subject']
        predicate = entities['predicate']
        object = entities['object']

        lastline = False
        if lines == totallines:
            lastline = True
        values = [subject, predicate, object]

        buildSqlBody(sqlScript, values, lastline)
        showProgress(lines, totallines)

# CREATE SQL SCRIPT FOR JOIN

print 'Creating sql script for categories join ...'

sqlScript = open('sql/categories_join.sql', 'w')

sqlScript.write('CREATE TABLE categories_join (\n')
sqlScript.write('\t category VARCHAR(127),\n')
sqlScript.write('\t subject VARCHAR(127),\n')
sqlScript.write('\t predicate VARCHAR(127),\n')
sqlScript.write('\t object VARCHAR(127)\n')
sqlScript.write(');\n')

sqlScript.write('INSERT INTO categories_join (category, subject, predicate, object)\n')
sqlScript.write('(SELECT c.category AS category, s.subject AS subject, s.predicate AS predicate, s.object AS object\n')
sqlScript.write('FROM `statements` AS s, `categories` AS c\n')
sqlScript.write('WHERE s.subject = c.subject\n')
sqlScript.write('ORDER BY category);\n')

# CREATE SQL SCRIPTS FOR CREATING (EMPTY) EVALUATION TABLES

print 'Creating sql scripts for evaluation tables ...'

sqlScript = open('sql/evaluation_tables.sql', 'w')

sqlScript.write('CREATE TABLE evaluation_results (\n')
sqlScript.write('\t category VARCHAR(127),\n')
sqlScript.write('\t predicate VARCHAR(127),\n')
sqlScript.write('\t object VARCHAR(127),\n')
sqlScript.write('\t probability VARCHAR(127)\n')
sqlScript.write(');\n')

sqlScript.write('CREATE TABLE suggestions (\n')
sqlScript.write('\t status VARCHAR(7),\n')
sqlScript.write('\t subject VARCHAR(127),\n')
sqlScript.write('\t predicate VARCHAR(127),\n')
sqlScript.write('\t object VARCHAR(127),\n')
sqlScript.write('\t probability FLOAT\n')
sqlScript.write(');\n')

