#!/bin/bash

docker run --name db_data -v /root/postgresql:/var/lib/postgresql wyaeld/postgres:data

docker run -p 5432:5432 --volumes-from db_data \
	-e POSTGRESQL_USER=tt -e POSTGRESQL_PASS=tt \
	-e POSTGRESQL_DB=tt_production wyaeld/postgres:9.3
