#!/bin/bash
DB_NAME=$1 # promo-es-prod
DB_PASSWORD=$2

CONTAINER_NAME=web
IP=$(docker inspect $CONTAINER_NAME | grep IPAddress | cut -d '"' -f 4)

echo $1
echo $2
echo $IP

mysqldump -uadmin -p$DB_PASSWORD -h $IP $DB_NAME > sql/$(date "+%s")-${DB_NAME}.sql
