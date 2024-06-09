require "rspec"
require_relative "../../../xmltool/config/config_loader"

describe XMLTool::ConfigLoader do
  describe ".load_config" do
    context "when the config file exists" do
      it "loads the configuration and returns the data" do
        expect(File).to receive(:exists?).with("path").and_return(true)
        expect(Psych).to receive(:load_file).with("path").and_return("data")
        expect(XMLTool::ConfigLoader.load_config("path")).to eq("data")
      end
    end

    context "when the config file does not exist" do
      it "raises a FileNotFoundError" do
        expect(File).to receive(:exists?).and_return(false)
        expect { XMLTool::ConfigLoader.load_config("path") }.to raise_error(XMLTool::FileNotFoundError)
      end
    end

    context "when an error occurs while loading the configuration" do
      it "raises a ConfigLoadError" do
        expect(File).to receive(:exists?).and_return(true)
        expect(Psych).to receive(:load_file).and_raise(Psych::Exception)
        expect { XMLTool::ConfigLoader.load_config("path") }.to raise_error(XMLTool::ConfigLoadError)
      end
    end
  end

  describe ".load_skill_config" do
    context "when the configuration files exist" do
      it "loads the child and parent configuration files and returns the data" do
        child_data = "child"
        parent_data = "parent"
        data = "child\nparent"

        expect(File).to receive(:exists?).with("child").and_return(true)
        expect(File).to receive(:exists?).with("parent").and_return(true)
        expect(File).to receive(:read).with("child").and_return(child_data)
        expect(File).to receive(:read).with("parent").and_return(parent_data)
        expect(Psych).to receive(:safe_load).with(data, aliases: true).and_return("data")
        expect(XMLTool::ConfigLoader.load_skill_config("child", "parent")).to eq("data")
      end
    end

    context "when the configuration files do not exist" do
      it "raises a FileNotFoundError" do
        expect(File).to receive(:exists?).and_return(false)
        expect { XMLTool::ConfigLoader.load_skill_config("child", "parent") }.to raise_error(XMLTool::FileNotFoundError)
      end
    end

    context "when an error occurs while reading the configuration files" do
      it "raises a FileReadError" do
        expect(File).to receive(:exists?).with("child").and_return(true)
        expect(File).to receive(:exists?).with("parent").and_return(true)
        expect(File).to receive(:read).and_raise(StandardError)
        expect { XMLTool::ConfigLoader.load_skill_config("child", "parent") }.to raise_error(XMLTool::FileReadError)
      end
    end

    context "when an error occurs while loading the configuration" do
      it "raises a ConfigLoadError" do
        expect(File).to receive(:exists?).with("child").and_return(true)
        expect(File).to receive(:exists?).with("parent").and_return(true)
        expect(File).to receive(:read).with("child").and_return("child")
        expect(File).to receive(:read).with("parent").and_return("parent")
        expect(Psych).to receive(:safe_load).and_raise(Psych::Exception)
        expect { XMLTool::ConfigLoader.load_skill_config("child", "parent") }.to raise_error(XMLTool::ConfigLoadError)
      end
    end
  end
end
