require "thor"
require_relative "cmd/skill"
require_relative "cmd/area"
require_relative "cmd/stats"
require_relative "command_logger"
require_relative "config/config_loader"
require_relative "config/config_generator"
require_relative "errors"
require_relative "utils/attr_utils"

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

      begin
        global_config = ConfigLoader.load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      skill = Skill.new(global_config["sources"], clazz, id)

      begin
        skill.load_config("config/skill/#{clazz}.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      skill.select_files
      skill.change_with(attrs, link)

      @logger.print_modified_files(skill.file_count, attrs.count)
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
    def area(name, mob, *attrs_raw)
      attrs = AttrUtils.parse_attrs(attrs_raw)
      areas = name.split("/")

      begin
        global_config = ConfigLoader.load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      area = Area.new(global_config["sources"], areas, mob)

      begin
        area.load_config("config/area.yml")
      rescue ConfigLoadError, AreaNotFoundError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      area.change_with(attrs)

      @logger.print_modified_files(area.file_count, attrs.count)
    end

    desc "stats CLASS RACE ATTRIBUTES", "modify player stats"
    def stats(clazz, race, *attrs_raw)
      attrs = AttrUtils.parse_attrs(attrs_raw)

      begin
        global_config = ConfigLoader.load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      stats = Stats.new(global_config["sources"], clazz, race)
      stats.change_with(attrs)

      @logger.print_modified_files(1, attrs.count)
    end

    desc "config CLASS", "generate config for class"
    def config(clazz)
      begin
        global_config = ConfigLoader.load_config("config/sources.yml")
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      config_gen = ConfigGenerator.new(global_config["sources"], clazz)
      config_gen.generate_config
    end
  end
end
