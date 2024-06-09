require "rspec"
require_relative "../../xmltool/app"

describe XMLTool::App do
  let(:app) { XMLTool::App.new }
  let(:logger) { XMLTool::XMLToolLogger.logger }
  let(:skill) { instance_double(XMLTool::Skill) }
  let(:area) { instance_double(XMLTool::Area) }
  let(:stats) { instance_double(XMLTool::Stats) }
  let(:attrs_raw) { ["attr1=value1", "attr2=value2"] }
  let(:attrs) { {"attr1" => "value1", "attr2" => "value2"} }
  
  before do
    allow(XMLTool::AttrUtils).to receive(:parse_attrs).and_return(attrs)
    
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
  end
  
  describe "#skill" do
    context "when called with class, id, and attributes" do
      before do
        allow(logger).to receive(:print_modified_files)
        allow(app).to receive(:ask).and_return("y")
      end

      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::Skill).to receive(:new).with("class", "id")
        expect(skill).to receive(:load_config).with("class", "y")
        expect(skill).to receive(:select_files)
        expect(skill).to receive(:change_with).with(attrs, "y")
        expect(skill).to receive(:file_count)
        
        app.skill("class", "id", *attrs_raw)
      end

      context "when skill.load_config raises a ConfigLoadError" do
        before do
          allow(skill).to receive(:load_config).and_raise(XMLTool::ConfigLoadError.new("Error message"))
        end

        it "logs the error and exits" do
          expect(logger).to receive(:log_error_and_exit).with("Error message")

          app.skill("class", "id", *attrs_raw)
        end
      end
    end
  end

  describe "#area" do
    context "when called with name, mob, and attributes" do
      before do
        allow(logger).to receive(:print_modified_files)
      end

      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::Area).to receive(:new).with(["name"], "mob")
        expect(area).to receive(:load_config).with("config/area.yml")
        expect(area).to receive(:change_with).with(attrs)
        expect(area).to receive(:file_count)
        
        app.area("name", "mob", *attrs_raw)
      end

      context "when area.load_config raises a ConfigLoadError" do
        before do
          allow(area).to receive(:load_config).and_raise(XMLTool::ConfigLoadError.new("Error message"))
        end

        it "logs the error and exits" do
          expect(logger).to receive(:log_error_and_exit).with("Error message")
          app.area("name", "mob", *attrs_raw)
        end
      end
    end
  end

  describe "#stats" do
    context "when called with class" do
      before do
        allow(logger).to receive(:print_modified_files)
      end

      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::Stats).to receive(:new).with("class", "race")
        expect(stats).to receive(:change_with).with(attrs)
        
        app.stats("class", "race", *attrs_raw)    
      end
    end
  end
end
