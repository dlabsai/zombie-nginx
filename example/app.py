from os import environ

from flask import Flask
import config


app = Flask(__name__)

environment = environ.get("FLASK_ENV", default="development")
if environment == "development":
    cfg = config.DevelopmentConfig()
elif environment == "production":
    cfg = config.ProductionConfig()

app.config.from_object(cfg)


@app.route("/")
def hello():
    return "Hello World"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # until we start using gunicorn
