require "nokogiri"
require "psych"
require_relative "../errors"
require_relative "../command_logger"
require_relative "../utils/file_utils"

module XMLTool
  class ConfigGenerator
    MAX_LEVEL = 39
    LV_START = -4
    LV_END = -1

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

      xml_base_values, yaml_skills, yaml_skills_child = parse_xml(path)
      yaml_skills, yaml_skills_child = generate_yaml_from_xml(xml_base_values, yaml_skills, yaml_skills_child)

      @logger.print_msg("Cleaning up YAML", :red, 1)
      clean_yaml(yaml_skills)
      clean_yaml(yaml_skills_child["variables"])

      yaml_skills = insert_aliases(yaml_skills, yaml_skills_child)
      yaml_skills_child = insert_anchors(yaml_skills_child)
      
      begin
        @logger.print_msg("Writing to file config/skill/#{@clazz}.yaml", :yellow)
        FileUtils.write_class_config(yaml_skills, @clazz)
        @logger.print_msg("Writing to file config/skill/children/#{@clazz}.yaml", :yellow)
        FileUtils.write_class_child_config(yaml_skills_child, @clazz)
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
      yaml_skills = {}
      yaml_skills_child = {}
      yaml_skills_child["variables"] = {}

      #determines whether the skill is level 01 and stores the attrs in xml_base_values
      @doc.css("SkillData Skill").select { |node| node["id"][LV_START..LV_END] == "0100" }.each do |node|
        id = node["id"]
        xml_base_values[id] = @attrs.each_with_object({"name" => node["name"]}) do |attr, hash|
          hash[attr] = node[attr] if node[attr]
        end
        yaml_skills[id] = {}
        yaml_skills[id]["children"] = "tmp"
        yaml_skills_child["variables"][id] = {}
      end

      [xml_base_values, yaml_skills, yaml_skills_child]
    end

    def generate_yaml_from_xml(xml_base_values, yaml_skills, yaml_skills_child)
      yaml_skills.each_key do |id|
        @logger.print_msg("Generating chain for skill #{id}", :light_black, 1)
        generate_chain(xml_base_values, yaml_skills, id)
        @logger.print_msg("Generating children for skill #{id}", :light_black, 1)
        generate_children(xml_base_values, yaml_skills, yaml_skills_child, id)
      end
      [yaml_skills, yaml_skills_child]
    end

    def generate_chain(xml_base_values, yaml_skills, id)
      (2..MAX_LEVEL).each do |i|
        level = i.to_s.rjust(2, "0") + "00"
        new_id = id.dup
        new_id[LV_START..LV_END] = level
        node = @doc.at_css("SkillData Skill[id=\"#{new_id}\"]")
        break unless node
        initial_obj = { "children" => "tmp", "name" => node["name"] }
        yaml_skills[id][new_id] = generate_skill_data(node, xml_base_values[id], initial_obj)
      end
    end

    def generate_children(xml_base_values, yaml_skills, yaml_skills_child, base_id)
      generate_children_levels(xml_base_values, yaml_skills_child, base_id)
      
      yaml_skills[base_id].each_key do |child_id|
        generate_children_levels(xml_base_values, yaml_skills_child, base_id, child_id)
      end
    end

    def generate_children_levels(xml_base_values, yaml_skills_child, base_id, child_id = base_id)
      (1..MAX_LEVEL).each do |i|
        new_id = child_id.chop.chop + i.to_s.rjust(2, "0")
        node = @doc.at_css("SkillData Skill[id=\"#{new_id}\"]")
        break unless node
        initial_obj = { "name" => node["name"] }
        yaml_skills_child["variables"][child_id] = {} unless yaml_skills_child["variables"][child_id]
        yaml_skills_child["variables"][child_id][new_id] = generate_skill_data(node, xml_base_values[base_id], initial_obj)
      end
    end

    def generate_skill_data(node, xml_base_values, initial_obj)
      @attrs.each_with_object(initial_obj) do |attr, hash|
        base = xml_base_values[attr]
        value = node[attr]
        next unless value && base

        modifier = 0
        modifier = (value.to_f / base.to_f - 1) * 100 unless base.to_f.zero?

        hash[attr] = format("%+0.0000f%%", modifier) unless modifier.negative? || modifier.zero?
      end
    end

    def insert_anchors(yaml_skills_child)
      yaml_string = yaml_skills_child.to_yaml(line_width: -1).gsub(/^---\n/, "")
      yaml_skills_child["variables"].each_key do |key|
        yaml_string.gsub!(/('#{key}':)/, "\\1 &#{key}")
      end
      yaml_string
    end

    def insert_aliases(yaml_skills, yaml_skills_child)
      yaml_string = yaml_skills.to_yaml(line_width: -1).gsub(/^---\n/, "")

      yaml_skills.each do |id, value|
        if yaml_skills_child["variables"].key?(id)
          yaml_string.gsub!(/('#{id}':\n\s*children:) tmp/, "\\1 *#{id}")
        else
          yaml_string.gsub!(/('#{id}':)\n\s*children: tmp/, "\\1")
        end

        value.each do |k, v|
          if yaml_skills_child["variables"].key?(k)
            yaml_string.gsub!(/('#{k}':\n\s*children:) tmp/, "\\1 *#{k}")
          else
            yaml_string.gsub!(/('#{k}':)\n\s*children: tmp/, "\\1")
          end
        end
      end
      yaml_string
    end

    def clean_yaml(yaml_obj)
      yaml_obj.each do |key, value|
        value.each do |k, v|
          if v.length == 2 && v.key?("name") && v.key?("children")
            v.delete("name")
            v.delete("children")
          end

          v.delete("name") if v.length == 1 && v.key?("name")
          v.delete_if { |_k, val| val.nil? } if v.is_a?(Hash)
          value.delete(k) if v.empty?
        end
        value.delete("children") if value.length == 1 && value.key?("children")
        yaml_obj.delete(key) if value.empty?
      end
    end
  end
end