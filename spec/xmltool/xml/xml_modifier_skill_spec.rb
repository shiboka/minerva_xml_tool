require "rspec"
require_relative "../../../xmltool/xml/xml_modifier_skill"

describe XMLTool::XMLModifierSkill do
  describe "#initialize" do
    it "initializes the XMLModifierSkill object" do
      nodes = Nokogiri::XML::Document.new
      expect(XMLTool::XMLModifierSkill.new(nodes)).to be_instance_of(XMLTool::XMLModifierSkill)
    end
  end

  describe "#change_skill_data" do
    let(:id) { "10100" }
    let(:attrs) { { "attr" => "100" } }
    let(:doc) { Nokogiri::XML("<Skill id=\"#{id}\"></Skill>") }
    let(:nodes) { doc.css("Skill") }
    let(:xml_modifier_skill) { XMLTool::XMLModifierSkill.new(nodes) }

    context "when the id does not exist" do
      it "does not change the skill data" do
        expect(nodes).to receive(:find_all).and_return([])
        expect(xml_modifier_skill.change_skill_data("invalid_id", attrs)).to eq([])
      end
    end

    context "when the id exists" do
      it "changes the skill data" do
        expect(nodes).to receive(:find_all).and_return(nodes)
        expect(xml_modifier_skill).to receive(:change_attr)
        xml_modifier_skill.change_skill_data(id, attrs)
      end
    end
  end
end
