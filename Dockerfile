FROM postgres:11-alpine

COPY init.sql /docker-entrypoint-initdb.d/

COPY fixtures/ /tmp/fixtures/