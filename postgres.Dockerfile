FROM postgres:10

RUN apt-get update && \
    apt-get install -fy postgresql-contrib-10 python-apt \
      postgresql-plpython-10 postgresql-10-debversion
