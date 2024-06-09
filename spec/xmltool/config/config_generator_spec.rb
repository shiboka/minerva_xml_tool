require "rspec"
require_relative "../../../xmltool/config/config_generator"

describe XMLTool::ConfigGenerator do
  describe "#initialize" do
    it "initializes the ConfigGenerator object" do
      expect(XMLTool::ConfigGenerator.new("clazz")).to be_instance_of(XMLTool::ConfigGenerator)
    end
  end

  describe "#generate_config" do
    let(:logger) { XMLTool::CLILogger.new }
    let(:sources) { { "server" => "datasheet", "client" => "database", "config" => "config" } }

    context "when the class is a Warrior" do
      it "generates the configuration files for the Warrior class" do
        config_generator = XMLTool::ConfigGenerator.new("warrior")
        config_generator.instance_variable_set(:@logger, logger)
        config_generator.instance_variable_set(:@sources, sources)

        expect(config_generator).to receive(:select_file).and_return("UserSkillData_Warrior_Popori_F.xml")
        expect(config_generator).to receive(:parse_file_to_doc).and_return("doc")
        expect(config_generator).to receive(:parse_base_values_and_init_skills).and_return(["base_values", "skills", "child_skills"])
        expect(config_generator).to receive(:populate_skills_from_base_values).with("base_values", "skills", "child_skills")
        expect(config_generator).to receive(:clean_both_skills).with("skills", "child_skills")
        expect(config_generator).to receive(:insert_aliases).with("skills", "child_skills").and_return("skills_string")
        expect(config_generator).to receive(:insert_anchors).with("child_skills").and_return("child_skills_string")
        expect(config_generator).to receive(:write_config_files).with("skills_string", "child_skills_string")
        
        config_generator.generate_config
      end
    end

    context "when the class is a Fighter" do
      it "generates the configuration files for the Fighter class" do
        config_generator = XMLTool::ConfigGenerator.new("fighter")
        config_generator.instance_variable_set(:@logger, logger)
        config_generator.instance_variable_set(:@sources, sources)

        expect(config_generator).to receive(:select_file).and_return("UserSkillData_Fighter_Human_F.xml")
        expect(config_generator).to receive(:parse_file_to_doc).and_return("doc")
        expect(config_generator).to receive(:parse_base_values_and_init_skills).and_return(["base_values", "skills", "child_skills"])
        expect(config_generator).to receive(:populate_skills_from_base_values).with("base_values", "skills", "child_skills")
        expect(config_generator).to receive(:clean_both_skills).with("skills", "child_skills")
        expect(config_generator).to receive(:insert_aliases).with("skills", "child_skills").and_return("skills_string")
        expect(config_generator).to receive(:insert_anchors).with("child_skills").and_return("child")
        expect(config_generator).to receive(:write_config_files).with("skills_string", "child")

        config_generator.generate_config
      end
    end

    context "when the class is a Glaiver" do
      it "generates the configuration files for the Glaiver class" do
        config_generator = XMLTool::ConfigGenerator.new("glaiver")
        config_generator.instance_variable_set(:@logger, logger)
        config_generator.instance_variable_set(:@sources, sources)

        expect(config_generator).to receive(:select_file).and_return("UserSkillData_Glaiver_Castanic_F.xml")
        expect(config_generator).to receive(:parse_file_to_doc).and_return("doc")
        expect(config_generator).to receive(:parse_base_values_and_init_skills).and_return(["base_values", "skills", "child_skills"])
        expect(config_generator).to receive(:populate_skills_from_base_values).with("base_values", "skills", "child_skills")
        expect(config_generator).to receive(:clean_both_skills).with("skills", "child_skills")
        expect(config_generator).to receive(:insert_aliases).with("skills", "child_skills").and_return("skills_string")
        expect(config_generator).to receive(:insert_anchors).with("child_skills").and_return("child")
        expect(config_generator).to receive(:write_config_files).with("skills_string", "child")

        config_generator.generate_config
      end
    end

    context "when an error occurs while generating the configuration files" do
      it "logs the error and exits" do
        config_generator = XMLTool::ConfigGenerator.new("clazz")
        config_generator.instance_variable_set(:@logger, logger)

        expect(config_generator).to receive(:select_file).and_return("file")
        expect(File).to receive(:join).and_raise(TypeError)
        expect(logger).to receive(:log_error_and_exit).with("TypeError")

        config_generator.generate_config
      end
    end
  end
end
