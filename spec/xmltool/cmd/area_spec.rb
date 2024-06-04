require "rspec"
require_relative "../../../xmltool/cmd/area"

describe XMLTool::Area do
  let(:sources) { ["source1", "source2"] }
  let(:areas) { ["area1", "area2"] }
  let(:mob) { "mob1" }
  let(:logger) { XMLTool::CommandLogger.new }
  let(:area) { XMLTool::Area.new(sources, areas, mob, logger) }

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

  describe '#change_with' do
    let(:attrs) { { 'key' => 'value' } }

    before do
      allow(area).to receive(:traverse_config)
    end

    it 'calls traverse_config with the correct arguments' do
      area.change_with(attrs)
      expect(area).to have_received(:traverse_config).with(area.instance_variable_get(:@config), attrs)
    end
  end
end