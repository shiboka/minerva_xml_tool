require "thor"
require "colorize"
require "psych"
require_relative "xmltool/skill"
require_relative "xmltool/util"

module XMLTool
  class App < Thor
    desc "hello NAME", "Say hello"
    def hello(name)
      puts "hello, #{name}"
    end

    desc "skill CLASS ID ATTRIBUTES", "modify skill"
    def skill(clazz, id, *attrs_raw)
      link = ask("Do you want to apply linked skills? (Y/N)").downcase
      
      attrs = parse_attrs(attrs_raw)
      config = Psych.load_file("config/sources.yml")

      skill = Skill.new(config, clazz, id)
      skill.load_config("config/skill/#{clazz}.yml")
      skill.select_files

      puts "", "Server:".red.bold
      skill.mode = :server
      skill.change_with(attrs, link)

      puts "", "Client:".red.bold
      skill.mode = :client
      skill.change_with(attrs, link)

      file_count = skill.files[:server].count + skill.files[:client].count
      puts "", "Modified #{attrs.count} attributes in #{file_count} files".red.bold
    end
  end
end

XMLTool::App.start(ARGV)
