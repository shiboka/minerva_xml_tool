require "nokogiri"
require_relative "command_logger"
require_relative "config"
require_relative "errors"
module XMLTool
  class Area
    attr_reader :file_count

    def initialize(sources, areas, mob)
      @logger = CommandLogger.new
      @sources = sources
      @areas = areas
      @mob = mob
      @file_count = 0
    end

    def load_config(path)
      @config = Config.load_config(path)

      @areas.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          raise AreaNotFoundError, "Area not found: #{a}"
        end
      end

      @config = { @areas.last => @config }
    end

    def change_with(attrs)
      traverse_config(@config, attrs)
    end

    private

    def traverse_config(cfg, attrs, areas = [], toggle = true)
      cfg.each do |key, value|
        if toggle && (key == "server" || key == "client")
          toggle = !toggle
          @logger.print_areas(areas)
        end

        if key == "server" || key == "client"
          @mode = key
          @logger.print_source(key)
        else
          areas.push(key)
        end

        if value.is_a?(Array)
          value.each do |v|
            change_attributes(v, attrs)
          end
        else
          traverse_config(value, attrs, areas, toggle)
        end

        areas.pop unless key == "server" || key == "client"
      end
    end

    def change_attributes(file, attrs)
      path = determine_path(file)
    
      if to_print_file(file, attrs)
        @logger.print_file(file, path)
        @file_count += 1
      end
    
      begin
      data = read_file(File.join(path, file))
      rescue FileNotFoundError, FileReadError => e
        @logger.log_error_and_exit(e.message)
      end

      begin
      doc = parse_xml(data)
      rescue XmlParseError => e
        @logger.log_error_and_exit(e.message)
      end

      handle_mob_case(doc, attrs)
    
      File.open(File.join("out/", path, file), "w") { |f| f.write(doc.root.to_xml) }
    end

    def determine_path(file)
      if @mode == "client"
        if file[/^NpcData/]
          @sources["client"] + "/NpcData"
        elsif file[/^TerritoryData/]
          @sources["client"] + "/TerritoryData"
        end
      else
        @sources["server"]
      end
    end

    def read_file(file)
      begin
        File.read(file)
      rescue Errno::ENOENT
        raise FileNotFoundError, "File not found: #{file}"
      rescue => e
        raise FileReadError, "Error reading file: #{e.message}"
      end
    end

    def parse_xml(data)
      begin
        Nokogiri::XML(data)
      rescue Nokogiri::XML::SyntaxError => e
        raise XmlParseError, "Error parsing XML: #{e.message}"
      end
    end

    def handle_mob_case(doc, attrs)
      has_respawn_time = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      case @mob
      when "small", "medium", "large"
        change_npc_data(doc, "size", @mob, attrs)
      when "elite"
        change_npc_data(doc, "elite", "true", attrs)
      when "all"
        if has_respawn_time
          change_territory_data(doc, nil, attrs)
          change_npc_data(doc, nil, nil, attrs) if multiple_attrs
        else
          change_npc_data(doc, nil, nil, attrs)
        end
      else
        if has_respawn_time
          change_territory_data(doc, @mob, attrs)
          change_npc_data(doc, "id", @mob, attrs) if multiple_attrs
        else
          change_npc_data(doc, "id", @mob, attrs)
        end
      end
    end

    def change_npc_data(doc, comp, comp_value, attrs)
      doc.css("NpcData Template").find_all { |n| comp ? n[comp] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["id"], node["desc"], node.line)
        attrs.each do |attr, value|
          change_npc_attr(node, attr, value)
        end
      end
    end

    def change_territory_data(doc, comp_value, attrs)
      doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comp_value ? n["npcTemplateId"] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["npcTemplateId"], node["desc"], node.line)
        attrs.each do |attr, value|
          change_territory_attr(node, attr, value)
        end
      end
    end

    def change_npc_attr(node, attr, value)
      case attr
      when "maxHp", "atk", "def"
        node.css("Stat").each do |node|
          node[attr] = value
          @logger.print_area_attr(attr, value, node.line)
        end
      when "str", "res"
        node.css("Critical").each do |node|
          node[attr] = value
          @logger.print_area_attr(attr, value, node.line)
        end
      end
    end

    def change_territory_attr(node, attr, value)
      if attr == "respawnTime"
        node[attr] = value
        @logger.print_area_attr(attr, value, node.line)
      end
    end

    def to_print_file(file, attrs)
      if file[/^NpcData/] && %w[maxHp atk def str res].any? { |key| attrs.key?(key) }
        true
      elsif file[/^TerritoryData/] && attrs.key?("respawnTime")
        true
      end
    end
  end
end