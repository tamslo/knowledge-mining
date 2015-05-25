import python.mikconfig as mikconfig

DB_USER = mikconfig.DB_USER
DB_PW = mikconfig.DB_PW
DB_HOST = mikconfig.DB_HOST
DB_NAME = mikconfig.DB_NAME

def get_db_init_config():
    return {
        'user': DB_USER,
        'password': DB_PW,
        'host': DB_HOST,
        'autocommit': True
    }

def get_db_config():
    return {
        'user': DB_USER,
        'password': DB_PW,
        'host': DB_HOST,
        'database': DB_NAME,
        'autocommit': True
    }


def get_queries(script):
    queries = []
    query = ""
    for line in script:
        if line.endswith("\n"):
            line = line[:-1]
        if line.startswith("    ") or line.startswith("\t"):
            line = line.replace("    ", " ")
            line = line.replace("\t", " ")
        if line.startswith("\n"):
            continue
        elif line.endswith(";\n") or line.endswith(";"):
            query += line
            queries.append(query)
            query = ""
        else:
            query += line
    return queries
