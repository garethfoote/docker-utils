#!/bin/bash

# Simple bash error checking.
errorCheck () {
    if [ $1 -eq 0 ]; then
        echo "Success: $2"
    else
        echo "Failed: $2 ($1)"
        exit $1
    fi
}

DB_NAME=db_name
DB_PASSWORD=password
CONTAINER_NAME=web
# Get env variables from .env file.
source .env

# If sql passed in from params then set.
if [ "$1" ]
then
    SQL_FILE=$1
fi

# Ensure docker + mysql is up and running.
RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting docker and MySQL"
    sleep 2
    IP=$(docker inspect $CONTAINER_NAME | grep IPAddress | cut -d '"' -f 4)
    echo "use mysql" | mysql -uadmin -p$DB_PASSWORD -h $IP
    RET=$?
done

# Drop and create.
echo "drop database $DB_NAME" | mysql -uadmin -p$DB_PASSWORD -h $IP
echo "create database $DB_NAME" | mysql -uadmin -p"${DB_PASSWORD}" -h $IP
errorCheck $? "create database"

# If sql file passed in then we populate database.
if [ "$SQL_FILE" ]
then
    mysql -uadmin -p$DB_PASSWORD -h $IP $DB_NAME < $SQL_FILE
fi
errorCheck $? "populate database"

echo $IP > ip.log
