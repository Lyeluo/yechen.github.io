#!/usr/bin/env bash
COMMAND=$0

sh ./images/batchloadimage.sh

docker-compose up -d
