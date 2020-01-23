import logging
from os import environ, urandom


class Config(object):
    def __init__(self):
        logging.basicConfig(level=logging.DEBUG)

    DEBUG = False
    TESTING = False
    SECRET_KEY = environ.get("APP_SECRET_KEY", default=urandom(16))


class DevelopmentConfig(Config):
    DEBUG = True
    SECRET_KEY = 'INSECURE_FOR_LOCAL_DEVELOPMENT'


class ProductionConfig(Config):
    DEBUG = False
    TESTING = False
