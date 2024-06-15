#!/bin/bash

# Sources
export DATASHEET=/path/to/xmltool/data/Datasheet
export DATABASE=/path/to/xmltool/data/Database
export CONFIG=/path/to/xmltool/config

# Docker image
export IMAGE=ghcr.io/shiboka/xmltool:main

# Run with Docker
docker run -p 4567:4567 -e DATASHEET=/xmltool/datasheet -e DATABASE=/xmltool/database -e CONFIG=/xmltool/config -v $CONFIG:/xmltool/config -v $DATASHEET:/xmltool/datasheet -v $DATABASE:/xmltool/database -it $IMAGE "$@"

# Run without Docker
#ruby xmltool.rb "$@"