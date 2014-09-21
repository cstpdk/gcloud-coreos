#!/bin/bash

docker run --name db_data -v /root/postgresql:/var/lib/postgresql wyaeld/postgres:data

docker run -p 5432:5432 --volumes-from db_data \
	-e POSTGRESQL_USER=quniz -e POSTGRESQL_PASS=quniz \
	-e POSTGRESQL_DB=quniz wyaeld/postgres:9.3
