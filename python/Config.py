class Config():

    def __init__(self):

        self.mysql_init_config = {
            'user': 'root',
            'password': '1234',
            'host': 'localhost',
            'autocommit': True
        }
        self.mysql_config = self.mysql_init_config
        self.mysql_config.update({'database': 'knowmin'})