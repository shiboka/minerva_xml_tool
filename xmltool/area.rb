module XMLTool
  class Area
    def initialize(sources, areas, mob)
      @sources = sources
      @areas = areas
      @mob = mob
    end

    def load_config(path)
      begin
        @config = Psych.load_file(path)
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end

      @areas.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          puts "Area not found: #{a}"
          exit
        end
      end

      @config = { @areas.last => @config }
    end

    def change_with(attrs)
      traverse_config(@config, attrs)
    end

    private

    def traverse_config(cfg, attrs, keys = [], toggle = true)
      cfg.each do |key, value|
        if toggle and (key == "server" or key == "client")
          toggle = !toggle
          puts "", "#{keys.join("/").cyan.bold}:"
        end

        if key == "server" or key == "client"
          @mode = key
          puts"#{key.capitalize.red.bold}:"
        else
          keys.push(key)
        end

        if value.is_a?(Array)
          value.each do |v|
            change_attributes(v, attrs)
          end
        else
          traverse_config(value, attrs, keys, toggle)
        end

        keys.pop unless key == "server" or key == "client"
      end
    end

    def change_attributes(file, attrs)
      path = determine_path(file)
    
      print_indent(1)
      puts "#{File.join(path, file).blue.bold}:"
    
      data = read_file(File.join(path, file))
      doc = parse_xml(data)
    
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
        puts "File not found: #{file}"
        exit
      rescue => e
        puts "Error reading file: #{e.message}"
        exit
      end
    end

    def parse_xml(data)
      begin
        Nokogiri::XML(data)
      rescue Nokogiri::XML::SyntaxError => e
        puts "Error parsing XML: #{e.message}"
        exit
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
        print_id_and_name(node["id"], node["desc"])
        attrs.each do |attr, value|
          change_npc_attr(node, attr, value)
        end
      end
    end

    def change_territory_data(doc, comp_value, attrs)
      doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comp_value ? n["npcTemplateId"] == comp_value : n }.each do |node|
        print_id_and_name(node["npcTemplateId"], node["desc"])
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
          print_attr(attr, value, node.line)
        end
      when "str", "res"
        node.css("Critical").each do |node|
          node[attr] = value
          pprint_attr(attr, value, node.line)
        end
      end
    end

    def change_territory_attr(node, attr, value)
      if attr == "respawnTime"
        node[attr] = value
        pprint_attr(attr, value, node.line)
      end
    end

    def print_id_and_name(templateId, desc)
      print_indent(2)
      puts "#{templateId.magenta}: #{desc ? desc.green : "???".green}"
    end

    def print_attr(attr, value, line)
      print_indent(3)
      puts "+ #{attr}=#{value}".yellow + " Line: #{line}".light_blue
    end

    def print_indent(indent)
      print "  " * indent
    end
  end
end