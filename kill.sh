#!/bin/bash
CONTAINER_NAME=web
DB_PASSWORD=password
source .env

if [ "$1" ]
then
    CONTAINER_NAME=$1
fi

docker kill $CONTAINER_NAME
docker rm $CONTAINER_NAME


