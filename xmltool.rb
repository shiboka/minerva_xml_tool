require "thor"
require "nokogiri"
require "psych"
require "colorize"
require_relative "xmltool/skill"
require_relative "xmltool/area"
require_relative "xmltool/command_logger"
require_relative "xmltool/util"

module XMLTool
  class App < Thor
    def self.exit_on_failure?
      true
    end

    desc "skill CLASS ID ATTRIBUTES", "modify skill"
    def skill(clazz, id, *attrs_raw)
      @logger = CommandLogger.new

      link = ask("Do you want to apply linked skills? (Y/N)").downcase
      attrs = parse_attrs(attrs_raw)

      begin
        global_config = load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
      end
        

      skill = Skill.new(global_config["sources"], clazz, id)

      begin
        skill.load_config("config/skill/#{clazz}.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
      end

      skill.select_files
      skill.change_with(attrs, link)

      puts "", "Modified #{attrs.count} attributes in #{skill.file_count} files".red.bold
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
    def area(name, mob, *attrs_raw)
      @logger = CommandLogger.new

      attrs = parse_attrs(attrs_raw)
      areas = name.split("/")

      begin
      global_config = load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
      end
      
      area = Area.new(global_config["sources"], areas, mob)

      begin
        area.load_config("config/area.yml")
      rescue ConfigLoadError, AreaNotFoundError => e
        @logger.log_error_and_exit(e.message)
      end

      area.change_with(attrs)

      puts "", "Modified #{attrs.count} attributes in #{area.file_count} files".red.bold
    end

    no_commands do
      def load_config(path)
        begin
          Psych.load_file(path)
        rescue Psych::Exception => e
          raise ConfigLoadError, "Error loading configuration: #{e.message}"
        end
      end
    end
  end
end

XMLTool::App.start(ARGV)
