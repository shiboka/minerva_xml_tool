require "rspec"
require_relative "../../../xmltool/cmd/skill"

describe XMLTool::SkillCommand do
  let(:logger) { instance_double(XMLTool::CLILogger) }
  let(:sources) { { "server" => "datasheet", "client" => "database", "config" => "config" } }
  let(:clazz) { "class" }
  let(:id) { "id" }
  let(:chain) { "y" }
  let(:skill_cmd) { XMLTool::SkillCommand.new(clazz, id, chain) }

  before do
    allow(XMLTool::CLILogger).to receive(:new).and_return(logger)
    skill_cmd.instance_variable_set(:@sources, sources)
  end

  describe "#run" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }

    before do
      allow(logger).to receive(:print_modified_files)
    end

    context "when files are present" do
      before do
        allow(Dir).to receive(:children).and_return(["file1", "file2", "file3"])
        allow(skill_cmd).to receive(:filter_files_by_pattern).and_return(["file1", "file2"])
        allow(skill_cmd).to receive(:filter_client_files).and_return(["file1", "file2"])
        allow(XMLTool::ConfigLoader).to receive(:load_skill_config).and_return({})
        allow(skill_cmd).to receive(:process_file)
      end

      it "calls process_file for each file" do
        expect(logger).to receive(:print_mode).twice
        expect(skill_cmd).to receive(:process_file).exactly(6).times

        skill_cmd.run(attrs)
      end
    end

    context "when files are not present" do
      before do
        allow(Dir).to receive(:children).and_return([])
        allow(XMLTool::ConfigLoader).to receive(:load_skill_config).and_return({})
      end

      it "does not call process_file" do
        expect(logger).not_to receive(:print_mode)
        expect(skill_cmd).not_to receive(:process_file)

        skill_cmd.run(attrs)
      end
    end
  end
end