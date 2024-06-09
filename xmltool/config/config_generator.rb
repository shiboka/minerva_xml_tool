require "nokogiri"
require "psych"
require_relative "../cmd/command"
require_relative "../errors"
require_relative "../utils/file_utils"

module XMLTool
  class ConfigGenerator < Command
    # MAX_LEVEL = maximum level of skill/child
    # LV_START/LV_END = level start and end indices of the skill ID
    MAX_LEVEL = 39
    LV_START = -4
    LV_END = -1
    ATTRS = ["totalAtk", "timeRate", "attackRange", "coolTime", "mp", "hp", "anger", "frontCancelEndTime", "rearCancelStartTime", "moveCancelStartTime"].freeze

    def initialize(clazz)
      super()
      @logger = logger
      @sources = sources
      @clazz = clazz
    end

    # Main method to generate the configuration files
    def generate_config
      begin
        file = select_file
        path = File.join(@sources["server"], file)

        @doc = parse_file_to_doc(path)
        base_values, skills, child_skills = parse_base_values_and_init_skills(path)

        populate_skills_from_base_values(base_values, skills, child_skills)
        clean_both_skills(skills, child_skills)

        skills_string = insert_aliases(skills, child_skills)
        child_skills_string = insert_anchors(child_skills)

        write_config_files(skills_string, child_skills_string)
      rescue TypeError => e
        @logger.log_error_and_exit(e.message)
      end
    end

    private

    # Selects the appropriate file based on the class
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

    # Parses the file to a Nokogiri::XML::Document
    def parse_file_to_doc(path)
      begin
        data = FileUtils.read_file(path)
        FileUtils.parse_xml(data)
      rescue FileNotFoundError, FileReadError => e
        @logger.log_error_and_exit("Error reading file: #{e.message}")
      rescue XmlParseError => e
        @logger.log_error_and_exit("Error parsing XML: #{e.message}")
      end
    end

    # Parses the base values of the parent skills from the XML Document
    # and initializes the skills and child_skills hashes
    def parse_base_values_and_init_skills(path)
      base_values = {}
      skills = {}
      child_skills = {"variables" => {}}

      @doc.css("SkillData Skill").select { |node| node["id"][LV_START..LV_END] == "0100" }.each do |node|
        id = node["id"]
        base_values[id] = ATTRS.each_with_object({"name" => node["name"]}) do |attr, hash|
          hash[attr] = node[attr] if node[attr]
        end
        skills[id] = {"children" => "tmp"}
        child_skills["variables"][id] = {}
      end

      [base_values, skills, child_skills]
    end

    # Populates the skills and child_skills hashes from the base values
    def populate_skills_from_base_values(base_values, skills, child_skills)
      skills.each_key do |id|
        @logger.print_msg("Generating chain for skill #{id}", :light_black, 1)
        populate_chain(id, base_values, skills)
        @logger.print_msg("Generating children for skill #{id}", :light_black, 1)
        populate_children(id, base_values, skills, child_skills)
      end
    end

    # Populates the chain (skill levels) for a given skill
    def populate_chain(id, base_values, skills)
      populate_levels(id, id, :chain, skills, base_values) { |node| { "children" => "tmp", "name" => node["name"] } }
    end

    # Populates the children (skill hits) for a given skill
    def populate_children(base_id, base_values, skills, child_skills)
      populate_children_levels(base_values, child_skills, base_id)
      
      skills[base_id].each_key do |child_id|
        populate_children_levels(base_values, child_skills, base_id, child_id)
      end
    end

    # Calls the populate_levels method to populate the children skills
    def populate_children_levels(base_values, child_skills, base_id, child_id = base_id)
      populate_levels(base_id, child_id, :children, child_skills["variables"], base_values) { |node| { "name" => node["name"] } }
    end

    # Populates a the leves/children of a skill with the skill data (attributes)
    def populate_levels(base_id, child_id, strategy, skills, base_values)
      (1..MAX_LEVEL).each do |i|
        new_id = generate_new_id(child_id, i, strategy)
        node = select_node(new_id)
        break unless node
        initial_obj = yield(node)
        skills[child_id] = {} unless skills[child_id]
        skills[child_id][new_id] = generate_skill_data(node, base_values[base_id], initial_obj)
      end
    end

    # Selects the node with the given id from the XML document
    def select_node(id)
      @doc.at_css("SkillData Skill[id=\"#{id}\"]")
    end

    # Generates a new id based on the given id, level, and strategy
    def generate_new_id(id, i, strategy)
      case strategy
      when :chain
        level = i.to_s.rjust(2, "0") + "00"
        new_id = id.dup
        new_id[LV_START..LV_END] = level
        new_id
      when :children
        id.chop.chop + i.to_s.rjust(2, "0")
      else
        raise ArgumentError, "Invalid strategy: #{strategy}"
      end
    end

    # Generates a hash of attributes with values based on the base value (parent skill value)
    # and the attribute value of the current skill
    def generate_skill_data(node, base_values, initial_obj)
      ATTRS.each_with_object(initial_obj) do |attr, hash|
        base = base_values[attr]
        value = node[attr]
        next unless value && base

        modifier = 0
        modifier = (value.to_f / base.to_f - 1) * 100 unless base.to_f.zero?

        hash[attr] = format("%+0.0000f%%", modifier) unless modifier.negative? || modifier.zero?
      end
    end

    # Inserts anchors into the YAML for child skills
    def insert_anchors(child_skills)
      yaml_with_anchors = yaml_to_string(child_skills)
      child_skills["variables"].each_key do |key|
        yaml_with_anchors = yaml_with_anchors.gsub(/('#{key}':)/, "\\1 &#{key}")
      end
      yaml_with_anchors
    end

    # Inserts aliases into the YAML for parent skills
    def insert_aliases(skills, child_skills)
      yaml_string = yaml_to_string(skills)

      skills.each do |id, value|
        yaml_string = replace_aliases(id, yaml_string, child_skills["variables"])
        value.each_key do |id|
          yaml_string = replace_aliases(id, yaml_string, child_skills["variables"])
        end
      end

      yaml_string
    end

    # Helper method for insert_aliases to insert aliases into the YAML if the skill has a child skill
    def replace_aliases(id, yaml_string, child_skills)
      if child_skills.key?(id)
        yaml_with_alias = yaml_string.gsub(/('#{id}':\n\s*children:) tmp/, "\\1 *#{id}")
      else
        yaml_with_alias = yaml_string.gsub(/('#{id}':)\n\s*children: tmp/, "\\1")
      end
      yaml_with_alias
    end

    # Converts a YAML object to a string
    def yaml_to_string(yaml_obj)
      yaml_obj.to_yaml(line_width: -1).gsub(/^---\n/, "")
    end

    # Cleans up both the parent skills and child_skills
    def clean_both_skills(skills, child_skills)
      @logger.print_msg("Cleaning up YAML", :red, 1)
      clean_skills(skills)
      clean_skills(child_skills["variables"])
    end

    # Main logic for cleaning the YAML, removes empty keys and values
    def clean_skills(yaml_obj)
      yaml_obj.each do |key, value|
        value.each do |k, v|
          if v.is_a?(Hash)
            if v.length == 2 && v.key?("name") && v.key?("children")
              v.delete("name")
              v.delete("children")
            elsif v.length == 1 && v.key?("name")
              v.delete("name")
            end

            v.delete_if { |_k, val| val.nil? }
            value.delete(k) if v.empty?
          end
        end

        value.delete("children") if value.length == 1 && value.key?("children")
        yaml_obj.delete(key) if value.empty?
      end
    end

    # Writes the parent skills and child skills to the config files
    def write_config_files(skills_string, child_skills_string)
      begin
        @logger.print_msg("Writing to file #{@sources["config"]}/skill/#{@clazz}.yaml", :yellow)
        FileUtils.write_class_config(skills_string, @clazz)
        @logger.print_msg("Writing to file #{@sources["config"]}/skill/children/#{@clazz}.yaml", :yellow)
        FileUtils.write_class_config(child_skills_string, @clazz, true)
      rescue FileWriteError => e
        @logger.log_error_and_exit("Error writing file: #{e.message}")
      end
    end
  end
end