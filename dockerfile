FROM postgres:latest

COPY DDL_apifestivos.sql /docker-entrypoint-initdb.d/
COPY DML_apifestivos.sql /docker-entrypoint-initdb.d/