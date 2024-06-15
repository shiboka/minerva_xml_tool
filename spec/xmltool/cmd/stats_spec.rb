require "rspec"
require_relative "../../../xmltool/cmd/stats"
require_relative "../../../xmltool/utils/file_utils"

describe XMLTool::StatsCommand do
  let(:logger) { instance_double(XMLTool::CLILogger) }
  let(:sources) { { "server" => "datasheet", "client" => "database" } }
  let(:clazz) { "class" }
  let(:race) { "race" }
  let(:stats_cmd) { XMLTool::StatsCommand.new(clazz, race) }

  before do
    allow(XMLTool::CLILogger).to receive(:new).and_return(logger)
    stats_cmd.instance_variable_set(:@sources, sources)
  end

  describe "#run" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }

    before do
      allow(logger).to receive(:print_modified_files)
    end

    context "when the file is processed properly" do
      it "processes the file with the given attributes" do
        allow(XMLTool::FileUtils).to receive(:read_file).and_return("data")
        allow(XMLTool::FileUtils).to receive(:parse_xml).and_return(Nokogiri::XML("<UserData></UserData>"))
        allow(XMLTool::FileUtils).to receive(:write_xml)

        expect(stats_cmd).to receive(:process_file).with("datasheet/UserData.xml", attrs)

        stats_cmd.run(attrs)
      end
    end

    context "when the file is not processed properly" do
      it "logs an error and exits if type error" do
        stats_cmd.instance_variable_set(:@sources, {})

        expect(logger).to receive(:log_error_and_exit).with("no implicit conversion of nil into String")

        stats_cmd.run(attrs)
      end
    end
  end
end