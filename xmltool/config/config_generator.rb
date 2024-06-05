require "nokogiri"
require "psych"
require_relative "../errors"
require_relative "../command_logger"
require_relative "../utils/file_utils"

module XMLTool
  class ConfigGenerator
    MAX_LEVEL = 39
    LV_START = -4
    LV_END = -3

    def initialize(sources, clazz, logger = CommandLogger.new)
      @logger = logger
      @sources = sources
      @clazz = clazz
      @attrs = ["totalAtk", "timeRate", "attackRange", "coolTime", "mp", "hp", "anger", "frontCancelEndTime", "rearCancelStartTime", "moveCancelStartTime"]
    end

    def generate_config
      file = select_file
      path = File.join(@sources["server"], file)

      begin
        data = FileUtils.read_file(path)
        @doc = FileUtils.parse_xml(data)
      rescue FileNotFoundError, FileReadError, XmlParseError => e
        @logger.log_error_and_exit(e.message)
      end

      @logger.print_file("conf/skill/#{@clazz}.yaml")
      xml_base_values, yaml_obj = parse_xml(path)
      yaml_obj = generate_yaml_from_xml(yaml_obj, xml_base_values)
      
      begin
        @logger.print_msg("Writing to file config/skill/#{@clazz}.yaml", :yellow)
        FileUtils.write_class_config(yaml_obj, @clazz)
      rescue FileWriteError => e
        @logger.log_error_and_exit(e.message)
      end
    end

    private

    def select_file
      case @clazz.capitalize
      when "Warrior", "Berserker", "Slayer", "Archer", "Sorcerer", "Lancer", "Priest", "Elementalist", "Soulless", "Engineer", "Assassin"
        "UserSkillData_#{@clazz.capitalize}_Popori_F.xml"
      when "Fighter"
        "UserSkillData_Fighter_Human_F.xml"
      when "Glaiver"
        "UserSkillData_Glaiver_Castanic_F.xml"
      end
    end

    def parse_xml(path)
      xml_base_values = {}
      yaml_obj = {}

      #determines whether the skill is level 01 and stores the attrs in xml_base_values
      @doc.css("SkillData Skill").select { |node| node["id"][LV_START..LV_END] == "01" }.each do |node|
        id = node["id"]
        xml_base_values[id] = @attrs.each_with_object({"name" => node["name"]}) do |attr, hash|
          hash[attr] = node[attr] if node[attr]
        end
        yaml_obj[id] = {}
      end

      [xml_base_values, yaml_obj]
    end

    def generate_yaml_from_xml(yaml_obj, xml_base_values)
      yaml_obj.each do |key, _value|
        @logger.print_msg("Generating chain for skill #{key}", :light_black, 1)
        generate_chain(yaml_obj, xml_base_values, key)
      end
      yaml_obj
    end

    def generate_chain(yaml_obj, xml_base_values, key)
      (2..MAX_LEVEL).each do |i|
        level = i.to_s.rjust(2, "0")
        new_id = key.dup
        new_id[LV_START..LV_END] = level
        node = @doc.at_css("SkillData Skill[id=\"#{new_id}\"]")
        if node
          yaml_obj[key][new_id] = generate_skill_data(node, xml_base_values[key])
        else
          break
        end
      end
    end

    def generate_skill_data(node, xml_base_values)
      @attrs.each_with_object({"name" => node["name"]}) do |attr, hash|
        base = xml_base_values[attr]
        value = node[attr]
        next unless value && base

        modifier = 0
        modifier = (value.to_f / base.to_f - 1) * 100 unless base.to_f.zero?

        hash[attr] = format("%+0.0000f%%", modifier) unless modifier.negative?
      end
    end
  end
end