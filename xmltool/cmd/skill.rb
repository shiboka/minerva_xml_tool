require "nokogiri"
require_relative "../command_logger"
require_relative "../utils/file_utils"
require_relative "../config"
require_relative "../errors"

module XMLTool
  class Skill
    attr_reader :file_count

    def initialize(sources, clazz, id)
      @logger = CommandLogger.new
      @sources = sources
      @clazz = clazz
      @id = id
      @files = {}
    end

    def load_config(path)
      @config = Config.load_config(path)
    end

    def select_files
      @sources.each do |key, path|
        path = key == "server" ? path : File.join(path, "SkillData")
        files = Dir.children(path)
        pattern = key == "server" ? /^UserSkillData_#{@clazz.capitalize}.+\.xml$/ : /^SkillData.+\.xml$/

        files.select! { |f| f[pattern] }
        files.map! { |f| File.join(path, f) }

        if key == "client"
          files.select! do |file|
            File.open(file, "r") do |f|
              data = f.read(512)
              data[/<Skill .+_[FM]_#{@clazz.capitalize}/]
            end
          end
        end

        @files[key] = files
      end

      @file_count = @files.values.flatten.count
    end

    def change_with(attrs, link)
      @files.each do |key, value|
        @logger.print_source(key)

        value.each do |file|
          process_file(file, attrs, link)
        end
      end
    end

    private

    def process_file(file, attrs, link)
      @logger.print_file(file)

      begin
        data = FileUtils.read_file(file)
        doc = FileUtils.parse_xml(data)
      rescue FileNotFoundError, FileReadError, XmlParseError => e
        @logger.log_error_and_exit(e.message)
      end

      nodes = doc.css("Skill")
      change_skill_data(nodes, @id, attrs)

      if link == "y"
        @config[@id.to_i].each do |config_id, config_attrs|
          change_skill_data(nodes, config_id.to_s, attrs, config_attrs)
        end
      end

      File.open(File.join("out/", file), "w") { |f| f.write(doc.root.to_xml) }
    end

    def change_skill_data(nodes, id, attrs, config_attrs = nil)
      nodes.find_all { |n| n["id"] == id }.each do |node|
        @logger.print_id_name_line(id, node["name"], node.line)
        
        attrs.each do |attr, value|
          result = calculate_result(value, config_attrs&.dig(attr))
          change_attr(node, attr, result)

          @logger.print_skill_attr(attr, result, config_attrs&.dig(attr))
        end
      end
    end

    def change_attr(node, attr, value)
      case attr
      when "mp", "hp", "anger"
        node.css("Precondition Cost").each do |node|
          node[attr] = value
        end
      when "coolTime"
        node.css("Precondition").each do |node|
          node[attr] = value
        end
      when "frontCancelEndTime", "rearCancelStartTime", "moveCancelStartTime"
        node.css("Action Cancel").each do |node|
          node[attr] = value
        end
      when "totalAtk", "timeRate", "attackRange"
        node[attr] = value
      end
    end

    def calculate_result(base_value, config_value)
      base = base_value.to_f
      if config_value
        mod = config_value.to_f
        base + base * mod
      else
        base
      end
    end
  end
end