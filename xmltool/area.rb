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
          @indent -= 1       
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

      #print "  " * i
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

      attrs.each do |attr, value|
        change_attribute(doc, attr, value)
      end
    end

    def change_attribute(doc, attr, value)
        case @mob
        when "all"
          if attr == "respawnTime"
            change_npc_spawn(doc, nil, attr, value)
          else
            change_npc_stat(doc, nil, nil, attr, value)
          end
        when "small"
          change_npc_stat(doc, "size", "small", attr, value)
        when "medium"
          change_npc_stat(doc, "size", "medium", attr, value)
        when "large"
          change_npc_stat(doc, "size", "large", attr, value)
        when "elite"
          change_npc_stat(doc, "elite", "true", attr, value)
        else
          if attr == "respawnTime"
            change_npc_spawn(doc, @mob, attr, value)
          else
            change_npc_stat(doc, "id", @mob, attr, value)
          end
        end
    end

    def change_npc_spawn(doc, comparer, attr, value)
      doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comparer ? n["npcTemplateId"] == comparer : n }.each do |node|
        node[attr] = value

        print_indent(2)
        puts "Line".magenta + ": #{node.line.to_s.green}"  
        print_indent(2)
        puts "#{node["npcTemplateId"].magenta}: #{node["desc"] ? node["desc"].green : "???".green}"
        print_indent(3)
        puts "+ #{attr}=#{value}".yellow
      end
    end

    def change_npc_stat(doc, comparer, size, attr, value)
      doc.css("NpcData Template").find_all { |n| comparer ? n[comparer] == size : n }.each do |node|
        case attr
        when "maxHp", "atk", "def"
          node.css("Stat").each do |node|
            node[attr] = value

            print_indent(2)
            puts "Line".magenta + ": #{node.line.to_s.green}"
            print_indent(2)
            puts "#{node.parent["id"].magenta}: #{node.parent["name"] ? node.parent["name"].to_s.green : "???".green}"
            print_indent(3)
            puts "+ #{attr}=#{value}".yellow
          end
        when "str", "res"
          node.css("Critical").each do |node|
            node[attr] = value
            
            print_indent(2)
            puts "Line".magenta + ": #{node.line.to_s.green}"
            print_indent(2)
            puts "#{node.parent["id"].magenta}: #{node.parent["name"] ? node.parent["name"].to_s.green : "???".green}"
            print_indent(3)
            puts "+ #{attr}=#{value}".yellow
          end
        end
      end
    end

    def print_indent(i = 0)
      print "  " * (@indent + i)
    end
  end
end