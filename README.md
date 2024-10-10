
### Running

```
git clone https://github.com/shiboka/minerva_xml_tool
cd minerva_xml_tool
docker compose up
```

---

### Configuration

#### Edit compose.yaml:

Before you run the program you should edit compose.yaml to point to the appropriate location on your pc. You only need to change "source" to point to the right location, do not change target or the program won't work.

```
volumes:
    - type: bind
        source: 'C:/Users/daubi/xmltool/datasheet'
        target: '/xmltool/datasheet'
    - type: bind
        source: 'C:/Users/daubi/xmltool/Database'
        target: '/xmltool/database'
    - type: bind
        source: 'C:/Users/daubi/xmltool/config'
        target: '/xmltool/config'
```

config can be any folder, we can generate all the config files into it.

---

### Config Generation

To generate config files for every class use the command:

```
config all
```

To target specific classes:

```
config warrior
```

You can do this in the web UI by using the "Direct" command option.

---

### Running as a CLI app

It is technically possible to run the program only in the console without the webui, but it's more complicated, for now it's easier to just use the web UI but I will update this portion at some point.

---