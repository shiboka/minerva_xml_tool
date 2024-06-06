
### Installation

Download the docker image:

```
docker pull ghcr.io/shiboka/xmltool:main
```

Download the start scripts:

```
curl -s https://api.github.com/repos/shiboka/minerva_xml_tool/releases/latest | jq -r '.assets[] | select(.name=="xmltool.zip") | .browser_download_url' | curl -L -O
```

Run it with:

```
./xmltool.sh
or
./xmltool.bat
```

---

### Configuration

Edit xmltool.sh/xmltool.bat:

Linux/Mac:
```
export DATASHEET=/path/to/xmltool/data/Datasheet
export DATABASE=/path/to/xmltool/data/Database
export CONFIG=/path/to/xmltool/config
```

Windows:
```
set DATASHEET=C:/path/to/xmltool/data/Datasheet
set DATABASE=C:/path/to/xmltool/data/Database
set CONFIG=C:/path/to/xmltool/config
```

CONFIG can be any ol' folder, we can generate all the config files into it:

---

### Generation

To generate every single config file:

```
./xmltool.sh rake config
```

To target specific things:

```
./xmltool.sh config warrior
```

---

### Running Locally

To run locally you will have to download the source code, then do this:

In xmltool.sh/xmltool.bat, uncomment this line:
```
ruby xmltool.rb "$@"
```

And comment this line:
```
docker run -e DATASHEET=$DATASHEET -e DATABASE=$DATABASE -e CONFIG=$CONFIG -v $CONFIG:$CONFIG -v $DATASHEET:$DATASHEET -v $DATABASE:$DATABASE -it $IMAGE "$@"
```

Make sure you have ruby, make, and gcc installed. Then run this from the source root directory:

```
gem install bundler
bundle install
```

Then you can run the start scripts as normal.

---

### TODO:

Add generation for the area config file, currently only skills are supported.