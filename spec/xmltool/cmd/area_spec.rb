require "rspec"
require_relative "../../../xmltool/cmd/area"

describe XMLTool::AreaCommand do
  let(:areas) { "area1/area2" }
  let(:mob) { "mob1" }
  let(:area_cmd) { XMLTool::AreaCommand.new(areas, mob) }
  let(:sources) { { "server" => "datasheet", "client" => "database", "config" => "config" } }

  before do
    area_cmd.instance_variable_set(:@sources, sources)
  end

  describe "#run" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }

    context "when the area is found in the config" do
      let(:config) { { "area2" => { "attr1" => "value1" } } }
      let(:path) { ["area1", "area2", "area2"] }

      before do
        area_cmd.instance_variable_set(:@config, config)
      end

      it "processes the value with the given attributes" do
        expect(area_cmd).to receive(:load_config)
        expect(area_cmd.instance_variable_get(:@config)).to eq(config)
        expect(area_cmd).to receive(:handle_toggle_and_mode).with("area2", true, path).and_return(true)
        expect(area_cmd).to receive(:process_value).with({ "attr1" => "value1" }, attrs, true, path)

        area_cmd.run(attrs)
      end
    end

    context "when the area is not found in the config" do
      let(:config) { { "area1" => {} } }

      before do
        area_cmd.instance_variable_set(:@config, config)
      end

      it "raises an AreaNotFoundError" do
        expect(XMLTool::ConfigLoader).to receive(:load_config).and_return(config)
        expect { area_cmd.run(attrs) }.to raise_error(XMLTool::AreaNotFoundError)
      end
    end

    context "when the config is empty" do
      let(:config) { {} }

      before do
        area_cmd.instance_variable_set(:@config, config)
      end

      it "does not process the value" do
        expect(area_cmd).to receive(:load_config)
        expect(area_cmd).not_to receive(:handle_toggle_and_mode)
        expect(area_cmd).not_to receive(:process_value)

        area_cmd.run(attrs)
      end
    end
  end
end
