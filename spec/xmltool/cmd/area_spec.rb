require "rspec"
require_relative "../../../xmltool/cmd/area"

describe XMLTool::Area do
  let(:areas) { ["area1", "area2"] }
  let(:mob) { "mob1" }
  let(:area) { XMLTool::Area.new(areas, mob) }

  describe "#load_config" do
    context "when the area is found in the config" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_return({ "area1" => { "area2" => "value" } })
      end

      it "loads the config for the area" do
        area.load_config("path")
        expect(area.instance_variable_get(:@config)).to eq({ "area2" => "value" })
      end
    end

    context "when the area is not found in the config" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_config).and_return({ "area1" => {} })
      end

      it "raises an AreaNotFoundError" do
        expect { area.load_config("path") }.to raise_error(XMLTool::AreaNotFoundError)
      end
    end
  end

  describe "#change_with" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }

    context "when the config is not empty" do
      let(:config) { { "area2" => { "attr1" => "value1" } } }

      it "processes the value with the given attributes" do
        expect(area).to receive(:handle_toggle).with("area2", true).and_return(true)
        expect(area).to receive(:handle_mode_and_area).with("area2")
        expect(area).to receive(:process_value).with({ "attr1" => "value1" }, attrs, true)

        area.change_with(attrs, config)
      end
    end

    context "when the config is empty" do
      let(:config) { {} }

      it "does not process the value" do
        expect(area).not_to receive(:handle_toggle)
        expect(area).not_to receive(:handle_mode_and_area)
        expect(area).not_to receive(:process_value)

        area.change_with(attrs, config)
      end
    end
  end
end