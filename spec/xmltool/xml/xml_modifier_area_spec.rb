require "rspec"
require_relative "../../../xmltool/xml/xml_modifier_area"

describe XMLTool::XMLModifierArea do
  describe "#initialize" do
    context "when the doc is a Nokogiri::XML::Document" do
      it "initializes the XMLModifierArea object" do
        doc = Nokogiri::XML::Document.new
        expect(XMLTool::XMLModifierArea.new(doc)).to be_instance_of(XMLTool::XMLModifierArea)
      end
    end

    context "when the doc is not a Nokogiri::XML::Document" do
      it "raises an ArgumentError" do
        expect { XMLTool::XMLModifierArea.new("doc") }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#handle_mob_case" do
    let(:doc) { Nokogiri::XML::Document.new }
    let(:xml_modifier_area) { XMLTool::XMLModifierArea.new(doc) }
    let(:mob) { "300811" }
    let(:attrs) { { "attr" => "value" } }

    context "when the mob is not a String" do
      it "raises an ArgumentError" do
        expect { xml_modifier_area.handle_mob_case(nil, attrs) }.to raise_error(ArgumentError)
      end
    end

    context "when the attrs are not a Hash" do
      it "raises an ArgumentError" do
        expect { xml_modifier_area.handle_mob_case(mob, nil) }.to raise_error(ArgumentError)
      end
    end

    context "when the mob is 'small'" do
      it "calls change_npc_data with the correct arguments" do
        expect(xml_modifier_area).to receive(:change_npc_data).with(attrs, "size", "small")
        xml_modifier_area.handle_mob_case("small", attrs)
      end
    end

    context "when the mob is 'medium'" do
      it "calls change_npc_data with the correct arguments" do
        expect(xml_modifier_area).to receive(:change_npc_data).with(attrs, "size", "medium")
        xml_modifier_area.handle_mob_case("medium", attrs)
      end
    end

    context "when the mob is 'large'" do
      it "calls change_npc_data with the correct arguments" do
        expect(xml_modifier_area).to receive(:change_npc_data).with(attrs, "size", "large")
        xml_modifier_area.handle_mob_case("large", attrs)
      end
    end

    context "when the mob is 'elite'" do
      it "calls change_npc_data with the correct arguments" do
        expect(xml_modifier_area).to receive(:change_npc_data).with(attrs, "elite", "true")
        xml_modifier_area.handle_mob_case("elite", attrs)
      end
    end

    context "when the mob is 'all'" do
      it "calls handle_id_all_case" do
        expect(xml_modifier_area).to receive(:handle_id_all_case).with(attrs)
        xml_modifier_area.handle_mob_case("all", attrs)
      end
    end

    context "when the mob is an id" do
      it "calls handle_id_all_case" do
        expect(xml_modifier_area).to receive(:handle_id_all_case).with(attrs, mob)
        xml_modifier_area.handle_mob_case(mob, attrs)
      end
    end
  end
end
