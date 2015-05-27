from python.DumpConverter import DumpConverter

converter = DumpConverter()
converter.convert_categories()
converter.convert_statements()
converter.write_hashes()
converter.delete_hashes()
