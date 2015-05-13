class Config():

    def __init__(self):

        DB_USER = 'root'
        DB_PW = '1234'
        DB_HOST = 'localhost'
        DB_NAME = 'knowmin'

        CATEGORIES_DUMP_PATH = '../dumps/article_categories_1000'
        STATEMENTS_DUMP_PATH = '../dumps/mappingbased_properties_1000'

        self.mysql_init_config = {
            'user': DB_USER,
            'password': DB_PW,
            'host': DB_HOST,
            'autocommit': True
        }
        self.mysql_config = self.mysql_init_config
        self.mysql_config.update({'database': DB_NAME})
        self.categories_dump_path = CATEGORIES_DUMP_PATH
        self.statements_dump_path = STATEMENTS_DUMP_PATH

    def get_mysql_config(self):
        return self.mysql_config

    def get_mysql_init_config(self):
        return self.mysql_init_config

    def get_categories_dump_path(self):
        return self.categories_dump_path

    def get_statements_dump_path(self):
        return self.statements_dump_path