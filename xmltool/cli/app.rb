require "thor"
require_relative "../cmd/skill"
require_relative "../cmd/area"
require_relative "../cmd/stats"
require_relative "../config/config_loader"
require_relative "../config/config_generator"
require_relative "../errors"
require_relative "../utils/attr_utils"
require_relative "logger"

module XMLTool
  class CLIApp < Thor
    class << self
      attr_accessor :logger
    end

    def initialize(*args)
      super
      if self.class.logger
        @logger = self.class.logger
      else
        @logger = CLILogger.new
      end
    end

    def self.exit_on_failure?
      true
    end

    desc "skill CLASS ID CHAIN ATTRIBUTES", "modify skill"
    long_desc <<-LONGDESC
      Will modify the skill with the given ID for the given class.

      The ATTRIBUTES argument should be a list of key-value pairs separated by an equal sign. For example: totalAtk=100.

      The command will prompt you to apply chained skills. If you choose to apply chained skills, the command will modify the chained skills specified in the config as well.

      Example:

      To modify the totalAtk of the warrior auto-attack skill::

      ruby xmltool.rb skill warrior 10100 totalAtk=100
    LONGDESC
    def skill(clazz, id, chain_raw, *attrs_raw)
      chain = chain_raw.downcase
      attrs = AttrUtils.parse_attrs(attrs_raw)

      skill_cmd = SkillCommand.new(clazz, id, chain, @logger)
      skill_cmd.run(attrs)
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

      Modify by a percentage:

      ruby xmltool.rb area fey_forest medium maxHp=+10%
    LONGDESC
    def area(name, mob, *attrs_raw)
      attrs = AttrUtils.parse_attrs(attrs_raw)

      area_cmd = AreaCommand.new(name, mob, @logger)
      area_cmd.run(attrs)
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

      stats_cmd = StatsCommand.new(clazz, race, @logger)
      stats_cmd.run(attrs)
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
      config_gen = ConfigGenerator.new(clazz, @logger)
      config_gen.generate_config
    end

    desc "rake ARGS", "run rake tasks"
    def rake(*args)
      system("rake #{args.join(' ')}")
    end
  end
end
