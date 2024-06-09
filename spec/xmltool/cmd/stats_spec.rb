require "rspec"
require_relative "../../../xmltool/cmd/stats"
require_relative "../../../xmltool/utils/file_utils"

describe XMLTool::Stats do
  let(:logger) { XMLTool::XMLToolLogger.logger }
  let(:sources) { { "server" => "datasheet", "client" => "database" } }
  let(:clazz) { "class" }
  let(:race) { "race" }
  let(:stats) { XMLTool::Stats.new(clazz, race) }

  before do
    stats.instance_variable_set(:@logger, logger)
    stats.instance_variable_set(:@sources, sources)
  end

  describe "#change_with" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }

    context "when the file is processed properly" do
      it "processes the file with the given attributes" do
        allow(XMLTool::FileUtils).to receive(:read_file).and_return("data")
        allow(XMLTool::FileUtils).to receive(:parse_xml).and_return(Nokogiri::XML("<UserData></UserData>"))
        allow(XMLTool::FileUtils).to receive(:write_xml)

        expect(stats).to receive(:process_file).with("datasheet/UserData.xml", attrs)

        stats.change_with(attrs)
      end
    end

    context "when the file is not processed properly" do
      it "logs an error and exits if type error" do
        stats.instance_variable_set(:@sources, {})

        expect(logger).to receive(:log_error_and_exit).with("no implicit conversion of nil into String")

        stats.change_with(attrs)
      end
    end
  end
end