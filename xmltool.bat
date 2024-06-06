@echo off
set DATASHEET=C:/path/to/xmltool/data/Datasheet
set DATABASE=C:/path/to/xmltool/data/Database
set CONFIG=C:/path/to/xmltool/config

REM Run the container
docker run -e DATASHEET=%DATASHEET% -e DATABASE=%DATABASE% -e CONFIG=%CONFIG% -v %CONFIG_HOST%:%CONFIG_CONTAINER% -v %DATA_HOST%:%DATA_CONTAINER% -it xmltool %*

REM Run without Docker
REM ruby xmltool.rb "$@"