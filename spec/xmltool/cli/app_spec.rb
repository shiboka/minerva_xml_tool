require "rspec"
require_relative "../../../xmltool/cli/app"

describe XMLTool::CLIApp do
  let(:app) { XMLTool::CLIApp.new }
  let(:logger) { instance_double(XMLTool::CLILogger) }
  let(:skill_cmd) { instance_double(XMLTool::SkillCommand) }
  let(:area_cmd) { instance_double(XMLTool::AreaCommand) }
  let(:stats_cmd) { instance_double(XMLTool::StatsCommand) }
  let(:attrs_raw) { ["attr1=value1", "attr2=value2"] }
  let(:attrs) { {"attr1" => "value1", "attr2" => "value2"} }
  
  before do
    allow(XMLTool::CLILogger).to receive(:new).and_return(logger)

    allow(XMLTool::AttrUtils).to receive(:parse_attrs).and_return(attrs)
    
    allow(XMLTool::SkillCommand).to receive(:new).and_return(skill_cmd)
    allow(skill_cmd).to receive(:run)
    
    allow(XMLTool::AreaCommand).to receive(:new).and_return(area_cmd)
    allow(area_cmd).to receive(:run)
    
    allow(XMLTool::StatsCommand).to receive(:new).and_return(stats_cmd)
    allow(stats_cmd).to receive(:run)
  end
  
  describe "#skill" do
    context "when called with class, id, and attributes" do
      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::SkillCommand).to receive(:new).with("class", "id", "y", logger)
        expect(skill_cmd).to receive(:run).with(attrs)
        
        app.skill("class", "id", "y", *attrs_raw)
      end
    end
  end

  describe "#area" do
    context "when called with name, mob, and attributes" do
      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::AreaCommand).to receive(:new).with("name", "mob", logger)
        expect(area_cmd).to receive(:run).with(attrs)
        
        app.area("name", "mob", *attrs_raw)
      end
    end
  end

  describe "#stats" do
    context "when called with class" do
      it "calls the necessary methods with the correct arguments" do
        expect(XMLTool::AttrUtils).to receive(:parse_attrs).with(attrs_raw)
        expect(XMLTool::StatsCommand).to receive(:new).with("class", "race", logger)
        expect(stats_cmd).to receive(:run).with(attrs)
        
        app.stats("class", "race", *attrs_raw)    
      end
    end
  end
end
