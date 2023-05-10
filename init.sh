#!/bin/bash

mkdir logs
chown -R 1001:1001 logs
cp -r exemple/* .
cp .env.default .env

#
### how to use ###
#

# chmod +x init.sh
# ./init.sh