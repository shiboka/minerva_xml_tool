require "thor"
require "nokogiri"
require "colorize"
require "psych"

module XMLTool
  class Skill
    attr_reader :files
    attr_accessor :mode

    def initialize(global_config, clazz, id)
      @clazz = clazz
      @id = id
      @sources = global_config["sources"]
      @config = Psych.load_file("config/skill/#{clazz}.yml")
      @files = {}
      load_server
      load_client
    end

    def change_with(attrs, link)
      @files[@mode].each do |file|
        puts file.blue.bold

        data = File.read(file)
        doc = Nokogiri::XML(data)
        nodes = doc.css("Skill")

        change_attributes(nodes, @id, attrs, attrs)
        @config[@id.to_i].each do |config_id, config_attrs|
          change_attributes(nodes, config_id.to_s, attrs, config_attrs)
        end if link == "y"
        File.open("out/" + file, "w") { |f| f.write(doc.to_xml) }
      end
    end

    private

    def load_server
      files = Dir.children(@sources["server"])
      files.select! { |f| f[/^UserSkillData_#{@clazz.capitalize}.+\.xml$/] }
      @files[:server] = files.map { |f| "#{@sources["server"]}/#{f}" }
    end

    def load_client
      @files[:client] = []
      path = "#{@sources["client"]}/SkillData/"

      files = Dir.children(path)
      files.select! { |f| f[/^SkillData.+\.xml$/] }

      files.each do |file|
        File.open(path + file) do |f|
          data = f.read(1024)
          filtered = data[/<Skill .+_[FM]_#{@clazz.capitalize}/]
          @files[:client].push(path + file) if filtered
        end
      end
    end

    def change_attributes(nodes, id, attrs, config_attrs)
      nodes.find_all { |n| n["id"] == id }.each do |node|
        puts "  #{id.magenta}: #{node["name"].green}"
        attrs.each do |key, value|
          change_attribute(node, key, config_attrs[key])
          puts "    + #{key}=#{config_attrs[key]}".yellow
        end
      end
    end

    def change_attribute(node, attr, value)
      if attr == "mp" || attr == "hp" || attr == "anger"
        node.children.css("Precondition").each do |node|
          node.children.css("Cost").each do |node|
            node[attr] = value
          end
        end
      elsif attr == "coolTime"
        node.children.css("Precondition").each do |node|
          node[attr] = value
        end
      elsif attr == "frontCancelEndTime" || attr == "rearCancelStartTime" || attr == "moveCancelStartTime"
        node.children.css("Action").each do |node|
          node.children.css("Cancel").each do |node|
            node[attr] = value
          end
        end
      elsif attr == "totalAtk" || attr == "timeRate" || attr == "attackRange"
        node[attr] = value
      end
    end
  end
end