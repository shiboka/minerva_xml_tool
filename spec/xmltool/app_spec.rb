require "rspec"
require_relative "../../xmltool/app"

describe XMLTool::App do
  let(:app) { XMLTool::App.new }
  let(:attrs_raw) { ["attr1=value1", "attr2=value2"] }
  let(:attrs) { {"attr1" => "value1", "attr2" => "value2"} }
  let(:global_config) { {"sources" => "source"} }
  let(:skill) { instance_double(XMLTool::Skill) }
  let(:area) { instance_double(XMLTool::Area) }
  let(:stats) { instance_double(XMLTool::Stats) }
  let(:config_generator) { instance_double("ConfigGenerator") }
  let(:clazz) { "SomeClass" }
  
  before do
    allow(XMLTool::AttrUtils).to receive(:parse_attrs).and_return(attrs)
    allow(XMLTool::ConfigLoader).to receive(:load_config).and_return(global_config)
    allow(XMLTool::Skill).to receive(:new).and_return(skill)
    allow(skill).to receive(:load_config)
    allow(skill).to receive(:select_files)
    allow(skill).to receive(:change_with)
    allow(skill).to receive(:file_count).and_return(1)
    
    allow(XMLTool::Area).to receive(:new).and_return(area)
    allow(area).to receive(:load_config)
    allow(area).to receive(:change_with)
    allow(area).to receive(:file_count).and_return(1)
    
    allow(XMLTool::Stats).to receive(:new).and_return(stats)
    allow(stats).to receive(:change_with)
    
    allow(XMLTool::ConfigGenerator).to receive(:new).and_return(config_generator)
    allow(config_generator).to receive(:generate_config)
  end
  
  describe "#skill" do
    it "calls the necessary methods with the correct arguments" do
      expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
      expect(XMLTool::ConfigLoader).to receive(:load_config).with("config/sources.yml")
      expect(XMLTool::Skill).to receive(:new).with(global_config["sources"], "class", "id")
      expect(skill).to receive(:load_config).with("config/skill/class.yml")
      expect(skill).to receive(:select_files)
      expect(skill).to receive(:change_with).with(attrs, "y")
      expect(skill).to receive(:file_count)
      
      app.skill("class", "id", *attrs_raw)
    end
  
    context "when ConfigLoader raises a ConfigLoadError" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_raise(XMLTool::ConfigLoadError)
      end
      
      it "logs the error and exits" do
        expect(app).to receive(:log_error_and_exit)
        app.skill("class", "id", *attrs_raw)
      end
    end
  end

  describe "#area" do
    it "calls the necessary methods with the correct arguments" do
      expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
      expect(XMLTool::ConfigLoader).to receive(:load_config).with("config/sources.yml")
      expect(XMLTool::Area).to receive(:new).with(global_config["sources"], ["name"], "mob")
      expect(area).to receive(:load_config).with("config/area.yml")
      expect(area).to receive(:change_with).with(attrs)
      expect(area).to receive(:file_count)
      
      app.area("name", "mob", *attrs_raw)
    end

    context "when ConfigLoader raises a ConfigLoadError" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_raise(XMLTool::ConfigLoadError)
      end
      
      it "logs the error and exits" do
        expect(app).to receive(:log_error_and_exit)
        app.area("name", "mob", *attrs_raw)
      end
    end
  end

  describe "#stats" do
    it "calls the necessary methods with the correct arguments" do
      expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
      expect(XMLTool::ConfigLoader).to receive(:load_config).with("config/sources.yml")
      expect(XMLTool::Stats).to receive(:new).with(global_config["sources"], "class", "race")
      expect(stats).to receive(:change_with).with(attrs)
      
      app.stats("class", "race", *attrs_raw)    
    end

    context "when ConfigLoader raises a ConfigLoadError" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_raise(XMLTool::ConfigLoadError)
      end
      
      it "logs the error and exits" do
        expect(app).to receive(:log_error_and_exit)
        app.stats("class", "race", *attrs_raw)
      end
    end
  end

  describe "#config" do
    it "calls ConfigLoader.load_config with correct argument" do
      app.config(clazz)
      expect(XMLTool::ConfigLoader).to have_received(:load_config).with("config/sources.yml")
    end

    it "calls ConfigGenerator.new with correct arguments" do
      app.config(clazz)
      expect(XMLTool::ConfigGenerator).to have_received(:new).with(global_config["sources"], clazz)
    end

    it "calls config_gen.generate_config" do
      app.config(clazz)
      expect(config_generator).to have_received(:generate_config)
    end

    context "when ConfigLoadError is raised" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_raise(XMLTool::ConfigLoadError)
      end
      
      it "logs error and exits" do
        expect(app).to receive(:log_error_and_exit)
        app.config(clazz)
      end
    end
  end
end
