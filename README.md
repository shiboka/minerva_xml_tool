
### Installation

Download the docker image:

```
docker pull ghcr.io/shiboka/xmltool:main
```

Download the start scripts:

```
curl -s https://api.github.com/repos/shiboka/minerva_xml_tool/releases/latest | jq -r '.assets[] | select(.name=="xmltool.zip") | .browser_download_url' | curl -L -O
```

---

### Configuration

Edit either xmltool.sh or xmltool.bat depending on your OS:

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



config can be just an empty folder, the config files can be generated:

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

### TODO:

Add generation for the area config file, currently only skills are supported.