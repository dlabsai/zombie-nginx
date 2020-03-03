FROM python:3.7-slim

RUN apt-get update
RUN apt-get install -y gcc

RUN mkdir /app/
ADD requirements.txt /app/

WORKDIR /app/
RUN pip install -r requirements.txt
COPY ./ /app/

RUN useradd --home-dir=/app --uid=1000 uwsgi_user

USER uwsgi_user

CMD uwsgi --strict uwsgi.ini