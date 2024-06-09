require "rspec"
require_relative "../../../xmltool/utils/file_utils"

describe XMLTool::FileUtils do
  describe ".read_file" do
    context "when the file exists" do
      it "reads the file and returns the data" do
        expect(File).to receive(:read).with("file").and_return("data")
        expect(XMLTool::FileUtils.read_file("file")).to eq("data")
      end
    end

    context "when the file does not exist" do
      it "raises a FileNotFoundError" do
        expect(File).to receive(:read).and_raise(Errno::ENOENT)
        expect { XMLTool::FileUtils.read_file("file") }.to raise_error(XMLTool::FileNotFoundError)
      end
    end

    context "when an error occurs while reading the file" do
      it "raises a FileReadError" do
        expect(File).to receive(:read).and_raise(StandardError)
        expect { XMLTool::FileUtils.read_file("file") }.to raise_error(XMLTool::FileReadError)
      end
    end
  end

  describe ".parse_xml" do
    context "when the XML data is valid" do
      it "parses the XML data and returns the document" do
        expect(Nokogiri).to receive(:XML).with("data").and_return("doc")
        expect(XMLTool::FileUtils.parse_xml("data")).to eq("doc")
      end
    end

    context "when the XML data is invalid" do
      it "raises an XmlParseError" do
        expect(Nokogiri).to receive(:XML).and_raise(Nokogiri::XML::SyntaxError)
        expect { XMLTool::FileUtils.parse_xml("data") }.to raise_error(XMLTool::XmlParseError)
      end
    end
  end

  describe ".write_xml" do
    context "when the file is written successfully" do
      it "writes the XML document to the file" do
        doc = double("doc", root: double("root", to_xml: "xml"))
        mock_file = double("file")
        expect(File).to receive(:open).with("file", "w").and_yield(mock_file)
        expect(mock_file).to receive(:write).with("xml")
        XMLTool::FileUtils.write_xml("file", doc)
      end
    end

    context "when an error occurs while writing the file" do
      it "does not write the file and raises a FileNotFoundError" do
        doc = double("doc", root: double("root", to_xml: "xml"))
        expect(File).to receive(:open).with("file", "w").and_raise(Errno::ENOENT)
        expect { XMLTool::FileUtils.write_xml("file", doc) }.to raise_error(XMLTool::FileNotFoundError)
      end

      it "does not write the file and raises a FileWriteError" do
        doc = double("doc", root: double("root", to_xml: "xml"))
        expect(File).to receive(:open).with("file", "w").and_raise(StandardError)
        expect { XMLTool::FileUtils.write_xml("file", doc) }.to raise_error(XMLTool::FileWriteError)
      end
    end
  end

  describe ".determine_path" do
    let(:sources) { { "server" => "datasheet", "client" => "database" } }

    context "when the mode is 'client' and the file is an NpcData file" do
      it "returns the client NpcData path" do
        expect(XMLTool::FileUtils.determine_path("NpcData", sources, "client")).to eq("database/NpcData")
      end
    end

    context "when the mode is 'client' and the file is a TerritoryData file" do
      it "returns the client TerritoryData path" do
        expect(XMLTool::FileUtils.determine_path("TerritoryData", sources, "client")).to eq("database/TerritoryData")
      end
    end

    context "when the mode is not 'client'" do
      it "returns the server path" do
        expect(XMLTool::FileUtils.determine_path("file", sources, "server")).to eq("datasheet")
      end
    end
  end

  describe ".write_class_config" do
    context "when child is false" do
      it "writes the YAML string to the class config file" do
        expect(ENV).to receive(:[]).with("CONFIG").and_return("config")
        expect(File).to receive(:join).with("config", "skill").and_return("skill_path")
        expect(Dir).to receive(:exist?).with("skill_path").and_return(false)
        expect(Dir).to receive(:mkdir).with("skill_path")
        expect(File).to receive(:join).with("skill_path", "Warrior.yml").and_return("skill_path/Warrior.yml")
        expect(File).to receive(:write).with("skill_path/Warrior.yml", "yaml")

        XMLTool::FileUtils.write_class_config("yaml", "Warrior")
      end
    end

    context "when child is true" do
      it "writes the YAML string to the class child config file" do
        expect(ENV).to receive(:[]).with("CONFIG").and_return("config")
        expect(File).to receive(:join).with("config", "skill", "children").and_return("skill_path")
        expect(Dir).to receive(:exist?).with("skill_path").and_return(false)
        expect(Dir).to receive(:mkdir).with("skill_path")
        expect(File).to receive(:join).with("skill_path", "Warrior.yml").and_return("skill_path/Warrior.yml")
        expect(File).to receive(:write).with("skill_path/Warrior.yml", "yaml")

        XMLTool::FileUtils.write_class_config("yaml", "Warrior", true)
      end
    end

    context "when an error occurs while writing the file" do
      it "does not write the file and raises a FileWriteError" do
        expect(ENV).to receive(:[]).and_raise(StandardError)
        expect { XMLTool::FileUtils.write_class_config("yaml", "Warrior") }.to raise_error(XMLTool::FileWriteError)
      end
    end
  end
end