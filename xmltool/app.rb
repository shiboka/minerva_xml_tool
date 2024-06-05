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
    long_desc <<-LONGDESC
      Will modify the skill with the given ID for the given class.

      The ATTRIBUTES argument should be a list of key-value pairs separated by an equal sign. For example: totalAtk=100.

      The command will prompt you to apply linked skills. If you choose to apply linked skills, the command will modify the linked skills specified in the config as well.

      Example:

      To modify the totalAtk of the warrior auto-attack skill::

      ruby xmltool.rb skill warrior 10100 totalAtk=100
    LONGDESC
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
        skill.load_config("config/skill/#{clazz}.yml", link)
      rescue ConfigLoadError => e
        @logger.log_error_and_exit(e.message)
        return
      end

      skill.select_files
      skill.change_with(attrs, link)

      @logger.print_modified_files(skill.file_count, attrs.count)
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
long_desc <<-LONGDESC
      Will modify the area of the given name for the given mob.

      MOB can be a mob ID or a size, i.e. small, medium, large, elite, or all.

      The ATTRIBUTES argument should be a list of key-value pairs separated by an equal sign. For example: maxHp=100.

      Examples:

      If your config defined an area oblivion_woods within an area arcadia, you could modify the maxHp attribute of an Oblivion Woods Basilisk like this:

      ruby xmltool.rb area arcadia/oblivion_woods 300811 maxHp=100

      To modify mobs of a specific size, you can use the size instead of the mob ID. For example, to modify all elite mobs in the area:

      ruby xmltool.rb area arcadia/oblivion_woods elite maxHp=100

      If you want to modify all mobs in the area, you can use the all keyword. For example, to modify all mobs in the area:

      ruby xmltool.rb area arcadia/oblivion_woods all maxHp=100

      If your config defined only a top-level area: fey_forest. You can modify the respawnTime of all small mobs in the area like this:

      ruby xmltool.rb area fey_forest small respawnTime=100
    LONGDESC
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
    long_desc <<-LONGDESC
      Will modify the stats of the given class and (optionally) race.

      The ATTRIBUTES argument should be a list of key-value pairs separated by an equal sign. For example: maxMp=100.

      Examples:

      To modify the maxMp of all warrior races:

      ruby xmltool.rb stats warrior all maxMp=100

      To modify the maxMp of a specific archer race:

      ruby xmltool.rb stats archer popori maxMp=100
    LONGDESC
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
    long_desc <<-LONGDESC
      Will generate a config file for the given class.

      Config files are saved in the config/skill directory.

      Example:

      To generate a config file for the warrior class:

      ruby xmltool.rb config warrior
    LONGDESC
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
