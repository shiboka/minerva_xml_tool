require "thor"
require "nokogiri"
require "psych"
require "colorize"
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
      global_config = load_config("config/sources.yml")

      skill = Skill.new(global_config["sources"], clazz, id)
      skill.load_config("config/skill/#{clazz}.yml")
      skill.select_files
      skill.change_with(attrs, link)

      puts "", "Modified #{attrs.count} attributes in #{skill.file_count} files".red.bold
    end

    desc "area NAME MOB ATTRIBUTES", "modify area"
    def area(name, mob, *attrs_raw)
      attrs = parse_attrs(attrs_raw)
      areas = name.split("/")
      global_config = load_config("config/sources.yml")
      
      area = Area.new(global_config["sources"], areas, mob)
      area.load_config("config/area.yml")
      area.change_with(attrs)
    end

    no_commands do
      def load_config(path)
        begin
          Psych.load_file(path)
        rescue Psych::Exception => e
          puts "Error loading configuration: #{e.message}"
          exit
        end
      end
    end
  end
end

XMLTool::App.start(ARGV)
