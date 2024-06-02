require "thor"
require "colorize"
require "psych"
require_relative "xmltool/skill"
require_relative "xmltool/area"
require_relative "xmltool/util"

module XMLTool
  class App < Thor
    def self.exit_on_failure?
      true
    end

    desc "skill CLASS ID ATTRIBUTES", "modify skill"
    def skill(clazz, id, *attrs_raw)
      link = ask("Do you want to apply linked skills? (Y/N)").downcase
      attrs = parse_attrs(attrs_raw)
      
      begin
        global_config = Psych.load_file("config/sources.yml")
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end

      skill = Skill.new(global_config["sources"], clazz, id)
      skill.load_config("config/skill/#{clazz}.yml")
      skill.select_files
      skill.change_with(attrs, link)

      puts "", "Modified #{attrs.count} attributes in #{skill.file_count} files".red.bold
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
    def area(name, mob, *attrs_raw)
      attrs = parse_attrs(attrs_raw)
      area_name = name.split("/")

      begin
        global_config = Psych.load_file("config/sources.yml")
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end
      
      area = Area.new(global_config["sources"], area_name, mob)
      area.load_config("config/area.yml")
      area.change_with(attrs)
    end
  end
end

XMLTool::App.start(ARGV)
