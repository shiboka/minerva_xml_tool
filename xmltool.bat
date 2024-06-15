@echo off

REM Sources
set DATASHEET=C:/path/to/xmltool/data/Datasheet
set DATABASE=C:/path/to/xmltool/data/Database
set CONFIG=C:/path/to/xmltool/config

REM Docker image
set IMAGE=ghcr.io/shiboka/xmltool:main

REM Run the container
docker run -p 4567:4567 -e DATASHEET=/xmltool/datasheet -e DATABASE=/xmltool/database -e CONFIG=/xmltool/config -v %CONFIG%:/xmltool/config -v %DATASHEET%:/xmltool/datasheet -v %DATABASE%:/xmltool/database -it %IMAGE% %*

REM Run without Docker
REM ruby xmltool.rb "$@"