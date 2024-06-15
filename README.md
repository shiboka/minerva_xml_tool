
### Installation

Download the docker image:

```
docker pull ghcr.io/shiboka/xmltool:main
```

#### Download the start scripts:

Linux/Mac

```
curl -L -O https://github.com/shiboka/minerva_xml_tool/releases/download/v0.1.0/xmltool.zip
```

Windows Powershell:

```
Invoke-WebRequest -Uri https://github.com/shiboka/minerva_xml_tool/releases/download/v0.1.0/xmltool.zip -OutFile xmltool.zip
```

Scripts will be in xmltool.zip

Run it with:

```
./xmltool.sh
or
xmltool.bat
```

---

### Configuration

#### Edit xmltool.sh/xmltool.bat:

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

DATASHEET and DATABASE, should point to the folder containing your TERA XML files for server and client, respectively.

CONFIG can be any folder, we can generate all the config files into it:

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

Or if you're running as a CLI app:

```
./xmltool.sh config all
or
xmltool.bat config all
```

---

### Running Locally

#### To run locally you will have to download the source code, then:

In xmltool.sh/xmltool.bat, uncomment this line:

```
ruby xmltool.rb "$@"
```

And comment this line:

```
docker run -p 4567:4567 -e DATASHEET=/xmltool/datasheet -e DATABASE=/xmltool/database -e CONFIG=/xmltool/config -v $CONFIG:/xmltool/config -v $DATASHEET:/xmltool/datasheet -v $DATABASE:/xmltool/database -it $IMAGE "$@"
```

Make sure you have ruby, make, and gcc installed. Then run this from the project root directory:

```
gem install bundler
bundle install
```

Then you can run the start scripts as normal.

---

### Running as a CLI app

#### First follow the instructions for running locally, then:

In xmltool.rb, uncomment these lines:

```
require_relative "xmltool/cli/app"
XMLTool::CLIApp.start(ARGV)
```

And comment these lines:

```
require_relative "xmltool/web/app"
XMLTool::WebApp.run!
```

---

### TODO:

Add generation for the areas config file, currently only skills are supported.

Git integration, using a git repo as the source for Datasheet/Database.

Setup is kind of complicated at the moment, I would like to simplify it.