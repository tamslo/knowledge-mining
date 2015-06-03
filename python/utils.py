import binascii

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

def mysql_hexlify(binary_string):
    return "X'" + binascii.hexlify(binary_string).decode('ascii') + "'"
