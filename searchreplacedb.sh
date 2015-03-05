#!/bin/bash

filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"

# sed "s|http://${1}|http://${2}|g" $3
sed "s|http://${1}|http://${2}|g" $3 > sql/${filename}.local.sql
