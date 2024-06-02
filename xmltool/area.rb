module XMLTool
  class Area
    def initialize(sources, area, mob)
      @sources = sources
      @area = area
      @mob = mob
      @indent = 0
    end

    def load_config(path)
      begin
        @config = Psych.load_file(path)
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end

      @area.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          puts "Area not found: #{a}"
          exit
        end
      end

      @config = { @area.last => @config }
    end

    def change_with(attrs)
      traverse_config(@config, attrs)
    end

    private

    def traverse_config(cfg, attrs)
      cfg.each do |key, value|
        if key == "server"
          @mode = :server
          print_indent
          puts "Server:".red.bold
        elsif key == "client"
          @mode = :client
          print_indent
          puts "Client:".red.bold
        else
          print_indent
          puts "#{key.cyan.bold}:"
        end

        if value.is_a?(Array)
          value.each do |v|
            change_attributes(v, attrs)
          end
        else
          @indent += 1
          traverse_config(value, attrs)      
        end
      end
    end

    def change_attributes(file, attrs)
      if @mode == :client
        if file[/^NpcData/]
          path = @sources["client"] + "/NpcData"
        elsif file[/^TerritoryData/]
          path = @sources["client"] + "/TerritoryData"
        end
      else
        path = @sources["server"]
      end

      print_indent(1)
      puts "#{File.join(path, file).blue.bold}:"

      begin
        data = File.read(File.join(path, file))
      rescue Errno::ENOENT
        puts "File not found: #{file}"
        exit
      rescue => e
        puts "Error reading file: #{e.message}"
        exit
      end

      begin
        doc = Nokogiri::XML(data)
      rescue Nokogiri::XML::SyntaxError => e
        puts "Error parsing XML: #{e.message}"
        exit
      end

      case @mob
      when "all"
        if attrs.key? "respawnTime" and attrs.length == 1
          change_territory_data(doc, nil, attrs)
        elsif attrs.key? "respawnTime" and attrs.length > 1
          change_territory_data(doc, nil, attrs)
          change_npc_data(doc, nil, nil, attrs)
        else
          change_npc_data(doc, nil, nil, attrs)
        end
      when "small", "medium", "large"
        change_npc_data(doc, "size", @mob, attrs)
      when "elite"
        change_npc_data(doc, "elite", "true", attrs)
      else
        if attrs.key? "respawnTime" and attrs.length == 1
          change_territory_data(doc, @mob, attrs)
        elsif attrs.key? "respawnTime" and attrs.length > 1
          change_territory_data(doc, @mob, attrs)
          change_npc_data(doc, "id", @mob, attrs)
        else
          change_npc_data(doc, "id", @mob, attrs)
        end
      end

    end



    def change_npc_data(doc, comp, comp_value, attrs)
      doc.css("NpcData Template").find_all { |n| comp ? n[comp] == comp_value : n }.each do |node|
        print_indent(2)
        puts "#{node["id"].to_s.magenta}: #{node["name"] ? node["name"].to_s.green : "???".green}"
        attrs.each do |attr, value|
          change_npc_attr(node, attr, value)
        end
      end
    end

    def change_npc_attr(node, attr, value)
      case attr
      when "maxHp", "atk", "def"
        node.css("Stat").each do |node|
          node[attr] = value
          print_indent(3)
          puts "+ #{attr}=#{value}".yellow + " Line: #{node.line}".light_blue
        end
      when "str", "res"
        node.css("Critical").each do |node|
          node[attr] = value
          print_indent(3)
          puts "+ #{attr}=#{value}".yellow + " Line: #{node.line}".light_blue
        end
      end
    end

    def change_territory_data(doc, comp_value, attrs)
      doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comp_value ? n["npcTemplateId"] == comp_value : n }.each do |node|
        print_indent(2)
        puts "#{node["npcTemplateId"].magenta}: #{node["desc"] ? node["desc"].green : "???".green}"
        attrs.each do |attr, value|
          change_territory_attr(node, attr, value)
        end
      end
    end

    def change_territory_attr(node, attr, value)
      if attr == "respawnTime"
        node[attr] = value
        print_indent(3)
        puts "+ #{attr}=#{value}".yellow + " Line: #{node.line}".light_blue
      end
    end

    def print_indent(i = 0)
      print "  " * (@indent + i)
    end
  end
end