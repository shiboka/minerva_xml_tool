#!/bin/bash

# Sources
export DATASHEET=/path/to/xmltool/data/Datasheet
export DATABASE=/path/to/xmltool/data/Database
export CONFIG=/path/to/xmltool/config

# Docker image
export IMAGE=ghcr.io/shiboka/xmltool:main

# Run with Docker
docker run -e DATASHEET=$DATASHEET -e DATABASE=$DATABASE -e CONFIG=$CONFIG -v $CONFIG:$CONFIG -v $DATASHEET:$DATASHEET -v $DATABASE:$DATABASE -it $IMAGE "$@"

# Run without Docker
#ruby xmltool.rb "$@"