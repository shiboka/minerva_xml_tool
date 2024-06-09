require "rspec"
require_relative "../../../xmltool/xml/xml_modifier_stats"

describe XMLTool::XMLModifierStats do
  describe "#initialize" do
    it "initializes the XMLModifierStats object" do
      nodes = Nokogiri::XML::Document.new
      expect(XMLTool::XMLModifierStats.new(nodes)).to be_instance_of(XMLTool::XMLModifierStats)
    end
  end

  describe "#change_stats_data" do
    let(:clazz) { "warrior" }
    let(:race) { "human" }
    let(:attrs) { { "attr" => "100" } }
    let(:doc) { Nokogiri::XML("<Stats class=\"#{clazz}\" race=\"#{race}\" gender=\"Male\"></Stats>") }
    let(:nodes) { doc.css("Stats") }
    let(:xml_modifier_stats) { XMLTool::XMLModifierStats.new(nodes) }

    context "race is not all" do
      it "filters the nodes by class and race and changes the attributes" do
        expect(nodes).to receive(:find_all).and_return(nodes)
        expect(xml_modifier_stats).to receive(:change_attr)
        xml_modifier_stats.change_stats_data(clazz, race, attrs)
      end
    end

    context "race is all" do
      it "filters the nodes by class and changes the attributes" do
        expect(nodes).to receive(:find_all).and_return(nodes)
        expect(xml_modifier_stats).to receive(:change_attr)
        xml_modifier_stats.change_stats_data(clazz, "all", attrs)
      end
    end

    context "when an invalid id is passed as an argument" do
      it "does not change the attributes" do
        expect(nodes).to receive(:find_all).and_return([])
        expect(xml_modifier_stats).not_to receive(:change_attr)
        expect(xml_modifier_stats.change_stats_data("invalid_id", race, attrs)).to eq([])
      end
    end
  end
end
