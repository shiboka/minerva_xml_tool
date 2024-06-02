module XMLTool
  class Area
    def initialize(sources, area, mob)
      @sources = sources
      @area = area
      @mob = mob
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
      traverse_config(@config, attrs, 0)
    end

    private

    def traverse_config(cfg, attrs, i)
      cfg.each do |key, value|
        if key == "server"
          @mode = :server
          print "  " * i
          puts "Server:".red.bold
        elsif key == "client"
          @mode = :client
          print "  " * i
          puts "Client:".red.bold
        else
          print "  " * i
          puts "#{key.blue.bold}:"
        end

        if value.is_a?(Array)
          value.each do |v|
            change_attributes(v, attrs, i + 1)
          end
        else
          traverse_config(value, attrs, i + 1)          
        end
      end
    end

    def change_attributes(file, attrs, i)
      if @mode == :client
        if file[/^NpcData/]
          path = @sources["client"] + "/NpcData/"
        elsif file[/^TerritoryData/]
          path = @sources["client"] + "/TerritoryData/"
        end
      else
        path = @sources["server"] + "/"
      end

      print "  " * i
      puts File.join(path, file).green

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

      attrs.each do |attr, value|
        change_attribute(doc, attr, value, i)
      end
    end

    def change_attribute(doc, attr, value, i)
        case @mob
        when "all"
          if attr == "respawnTime"
            change_npc_spawn(doc, nil, attr, value, i + 1)
          else
            change_npc_stat(doc, nil, nil, attr, value, i + 1)
          end
        when "small"
          change_npc_stat(doc, "size", "small", attr, value, i + 1)
        when "medium"
          change_npc_stat(doc, "size", "medium", attr, value, i + 1)
        when "large"
          change_npc_stat(doc, "size", "large", attr, value, i + 1)
        when "elite"
          change_npc_stat(doc, "elite", "true", attr, value, i + 1)
        else
          if attr == "respawnTime"
            change_npc_spawn(doc, @mob, attr, value, i + 1)
          else
            change_npc_stat(doc, "id", @mob, attr, value, i + 1)
          end
        end
    end

    def change_npc_spawn(doc, comparer, attr, value, i)
      doc.css("TerritoryData TerritoryGroup TerritoryList Territory Party Npc").find_all do |n|
        comparer ? n["npcTemplateId"] == comparer : n
      end.each do |node|
        print "  " * i
        puts "respawnTime=#{value}".yellow
        node["respawnTime"] = value
      end
    end

    def change_npc_stat(doc, comparer, size, attr, value, i)
      doc.css("NpcData Template").find_all { |n| comparer ? n[comparer] == size : n }.each do |node|
        case attr
        when "maxHp", "atk", "def"
          node.css("Stat").each do |node|
            print "  " * i
            puts "ID: #{node.parent["id"].magenta}:"
            print "  " * (i + 1)
            puts "#{attr}=#{value}".yellow
            node[attr] = value
          end
        when "str", "res"
          node.css("Critical").each do |node|
            print "  " * i
            puts "#{attr}=#{value}".yellow
            node[attr] = value
          end
        end
      end
    end
    
  end
end