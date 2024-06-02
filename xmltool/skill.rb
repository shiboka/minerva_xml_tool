require "thor"
require "nokogiri"
require "colorize"
require "psych"

module XMLTool
  class Skill
    attr_reader :file_count

    def initialize(sources, clazz, id)
      @sources = sources
      @clazz = clazz
      @id = id
      @files = {}
    end

    def load_config(path)
      begin
        @config = Psych.load_file(path)
      rescue Psych::Exception => e
        puts "Error loading configuration: #{e.message}"
      end
    end

    def select_files
      files = Dir.children(@sources["server"])
      files.select! { |f| f[/^UserSkillData_#{@clazz.capitalize}.+\.xml$/] }
      @files[:server] = files.map { |f| "#{@sources["server"]}/#{f}" }

      path = "#{@sources["client"]}/SkillData/"
      @files[:client] = Dir.children(path).select { |f| f[/^SkillData.+\.xml$/] }.select do |file|
        File.open(File.join(path, file), "r") do |f|
          data = f.read(512)
          data[/<Skill .+_[FM]_#{@clazz.capitalize}/]
        end
      end.map { |f| "#{path}#{f}" }

      @file_count = @files[:server].count + @files[:client].count
    end

    def change_with(attrs, link)
      @files.each do |key, value|
        if key == :server
          puts "Server:".red.bold
        elsif key == :client
          puts "Client:".red.bold
        end

        @files[key].each do |file|
          puts file.blue.bold

          begin
            data = File.read(file)
          rescue Errno::ENOENT
            puts "File not found: #{file}"
          rescue => e
            puts "Error reading file: #{e.message}"
          end

          begin
            doc = Nokogiri::XML(data)
          rescue Nokogiri::XML::SyntaxError => e
            puts "Error parsing XML: #{e.message}"
          end
          
          nodes = doc.css("Skill")

          change_attributes(nodes, @id, attrs)
          @config[@id.to_i].each do |config_id, config_attrs|
            change_attributes(nodes, config_id.to_s, attrs, config_attrs)
          end if link == "y"

          File.open(File.join("out/", file), "w") { |f| f.write(doc.root.to_xml) }
        end
      end
    end

    private

    def change_attributes(nodes, id, attrs, config_attrs = nil)
      nodes.find_all { |n| n["id"] == id }.each do |node|
        puts "  #{id.magenta}: #{node["name"].green}"
        
        attrs.each do |attr, value|
          if config_attrs
            base = value.to_f
            mod = config_attrs[attr].to_f
            result = base + base * mod
          else
            result = value.to_f
          end

          change_attribute(node, attr, result)

          outstr = "    + #{attr}=#{result}".yellow
          outstr += " " + config_attrs[attr].light_blue if config_attrs
          puts outstr
        end
      end
    end

    def change_attribute(node, attr, value)
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
  end
end