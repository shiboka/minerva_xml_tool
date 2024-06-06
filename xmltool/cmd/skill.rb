require_relative "command"
require_relative "../command_logger"
require_relative "../utils/file_utils"
require_relative "../xml/xml_modifier_skill"
require_relative "../config/config_loader"
require_relative "../errors"

module XMLTool
  class Skill < Command
    attr_accessor :config
    attr_reader :file_count

    def initialize(clazz, id)
      super()
      @logger = logger
      @sources = sources
      @clazz = clazz
      @id = id
      @files = {}
    end

    def load_config(clazz, link)
      @config = link == "n" ? {} : ConfigLoader.load_skill_config(@sources["config"] + "/skill/children/#{clazz}.yml", @sources["config"] + "/skill/#{clazz}.yml")
    end

    def select_files
      @sources.each do |key, path|
        path = key == "server" || key == "config" ? path : File.join(path, "SkillData")
        files = Dir.children(path)
        files = filter_files_by_pattern(files, key)
        files = files.map { |f| File.join(path, f) }
        files = filter_client_files(files, key)
        @files[key] = files
      end

      @file_count = @files.values.flatten.count
    end

    def change_with(attrs, link)
      @files.each do |key, value|
        @logger.print_mode(key) unless key == "config"

        value.each do |file|
          process_file(file, attrs, link)
        end
      end
    end

    private

    def filter_files_by_pattern(files, key)
      pattern = key == "server" ? /^UserSkillData_#{@clazz.capitalize}.+\.xml$/ : /^SkillData.+\.xml$/
      files.select { |f| f[pattern] }
    end

    def filter_client_files(files, key)
      if key == "client"
        files.select do |file|
          File.open(file, "r") do |f|
            data = f.read(512)
            data[/<Skill .+_[FM]_#{@clazz.capitalize}/]
          end
        end
      else
        files
      end
    end

    def process_file(file, attrs, link)
      @logger.print_file(file)

      begin
        data = FileUtils.read_file(file)
        doc = FileUtils.parse_xml(data)
      rescue FileNotFoundError, FileReadError, XmlParseError => e
        @logger.log_error_and_exit(e.message)
      end

      nodes = doc.css("Skill")
      xml_modifier = XMLModifierSkill.new(nodes)
      xml_modifier.change_skill_data(@id, attrs)

      if link == "y"
        @config[@id]["children"].each do |config_id, config_attrs|
          xml_modifier.change_skill_data(config_id, attrs, config_attrs)
        end if @config[@id]["children"]

        @config[@id].each do |config_id, config_attrs|
          xml_modifier.change_skill_data(config_id, attrs, config_attrs)

          config_attrs["children"].each do |config_id, config_attrs|
            xml_modifier.change_skill_data(config_id, attrs, config_attrs)
          end if config_attrs["children"]
        end
      end

      begin
        @sources.each_value do |source|
          FileUtils.write_xml(file, doc)
        end
      rescue FileWriteError => e
        @logger.log_error_and_exit(e.message)
      end
    end
  end
end