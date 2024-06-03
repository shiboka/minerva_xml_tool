require "thor"
require_relative "xmltool/cmd/skill"
require_relative "xmltool/cmd/area"
require_relative "xmltool/cmd/stats"
require_relative "xmltool/command_logger"
require_relative "xmltool/config"
require_relative "xmltool/errors"
require_relative "xmltool/utils/attr_utils"

module XMLTool
  class App < Thor
    def initialize(*args)
      super
      @logger = CommandLogger.new
    end

    def self.exit_on_failure?
      true
    end

    desc "skill CLASS ID ATTRIBUTES", "modify skill"
    def skill(clazz, id, *attrs_raw)
      link = ask("Do you want to apply linked skills? (Y/N)").downcase
      attrs = AttrUtils.parse_attrs(attrs_raw)

      global_config = Config.load_config("config/sources.yml")
      skill = Skill.new(global_config["sources"], clazz, id)

      begin
        skill.load_config("config/skill/#{clazz}.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
      end

      skill.select_files
      skill.change_with(attrs, link)
      @logger.print_modified_files(skill.file_count, attrs.count)
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
    def area(name, mob, *attrs_raw)
      attrs = AttrUtils.parse_attrs(attrs_raw)
      areas = name.split("/")

      global_config = Config.load_config("config/sources.yml")
      area = Area.new(global_config["sources"], areas, mob)

      begin
        area.load_config("config/area.yml")
      rescue ConfigLoadError, AreaNotFoundError => e
        @logger.log_error_and_exit(e.message)
      end

      area.change_with(attrs)
      @logger.print_modified_files(area.file_count, attrs.count)
    end

    desc "stats CLASS RACE ATTRIBUTES", "modify player stats"
    def stats(clazz, race, *attrs_raw)
      attrs = AttrUtils.parse_attrs(attrs_raw)
      global_config = Config.load_config("config/sources.yml")
      stats = Stats.new(global_config["sources"], clazz, race)
      
      stats.change_with(attrs)
      @logger.print_modified_files(1, attrs.count)
    end
  end
end

XMLTool::App.start(ARGV)
