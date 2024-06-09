require "rspec"
require_relative "../../../xmltool/cmd/skill"

describe XMLTool::Skill do
  let(:logger) { XMLTool::XMLToolLogger.logger }
  let(:sources) { { "server" => "datasheet", "client" => "database", "config" => "config" } }
  let(:clazz) { "class" }
  let(:id) { "id" }
  let(:skill) { XMLTool::Skill.new(clazz, id) }

  before do
    skill.instance_variable_set(:@logger, logger)
    skill.instance_variable_set(:@sources, sources)
  end

  describe "#load_config" do
    let(:link) { "y" }

    context "when config loads properly" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_skill_config).and_return({})
      end

      it "loads the config" do
        expect(XMLTool::ConfigLoader).to receive(:load_skill_config).with("config/skill/children/class.yml", "config/skill/class.yml")

        skill.load_config(clazz, link)

        expect(skill.config).to eq({})
      end
    end

    context "when config load error occurs" do
      before do
        allow(XMLTool::ConfigLoader).to receive(:load_skill_config).and_raise(XMLTool::ConfigLoadError)
      end

      it "logs an error and exits" do
        expect(logger).to receive(:log_error_and_exit).with("XMLTool::ConfigLoadError")

        skill.load_config(clazz, link)
      end
    end

    context "when method error occurs" do
      before do
        skill.instance_variable_set(:@sources, {})
      end

      it "logs an error and exits" do
        expect(logger).to receive(:log_error_and_exit) do |msg|
          expect(msg).to include("undefined method `+' for nil:NilClass")
        end

        skill.load_config(clazz, link)
      end
    end
  end

  describe "#select_files" do
    context "when files are present" do
      before do
        allow(Dir).to receive(:children).and_return(["file1", "file2", "file3"])
        allow(skill).to receive(:filter_files_by_pattern).and_return(["file1", "file2"])
        allow(skill).to receive(:filter_client_files).and_return(["file1", "file2"])
      end

      it "selects the correct files" do
        expect(Dir).to receive(:children).exactly(3).times
        expect(skill).to receive(:filter_files_by_pattern).exactly(3).times
        expect(skill).to receive(:filter_client_files).exactly(3).times

        skill.select_files

        expect(skill.file_count).to eq(6)
      end
    end

    context "when file error occurs" do
      before do
        allow(Dir).to receive(:children).and_raise(Errno::ENOENT)
      end

      it "logs an error and exits" do
        expect(logger).to receive(:log_error_and_exit) do |msg|
          expect(msg).to include("No such file or directory")
        end

        skill.select_files
      end
    end
  end

  describe "#change_with" do
    let(:attrs) { { "attr1" => "value1", "attr2" => "value2" } }
    let(:link) { "y" }

    context "when files are present" do
      before do
        skill.instance_variable_set(:@files, { "server" => ["file1", "file2"], "client" => ["file1", "file2"] })
        allow(skill).to receive(:process_file)
      end

      it "calls process_file for each file" do
        expect(logger).to receive(:print_mode).twice
        expect(skill).to receive(:process_file).exactly(4).times

        skill.change_with(attrs, link)
      end
    end

    context "when files are not present" do
      before do
        skill.instance_variable_set(:@files, { "server" => [], "client" => [] })
      end

      it "does not call process_file" do
        expect(logger).not_to receive(:print_mode)
        expect(skill).not_to receive(:process_file)

        skill.change_with(attrs, link)
      end
    end
  end
end