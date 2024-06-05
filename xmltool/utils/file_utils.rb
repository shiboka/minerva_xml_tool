require "nokogiri"
require_relative "../errors"

module XMLTool
  class FileUtils
    def self.read_file(file)
      begin
        File.read(file)
      rescue Errno::ENOENT
        raise FileNotFoundError, "File not found: #{file}"
      rescue => e
        raise FileReadError, "Error reading file: #{e.message}"
      end
    end

    def self.parse_xml(data)
      begin
        Nokogiri::XML(data)
      rescue Nokogiri::XML::SyntaxError => e
        raise XmlParseError, "Error parsing XML: #{e.message}"
      end
    end

    def self.determine_path(file, sources, mode)
      if mode == "client"
        if file[/^NpcData/]
          sources["client"] + "/NpcData"
        elsif file[/^TerritoryData/]
          sources["client"] + "/TerritoryData"
        end
      else
        sources["server"]
      end
    end

    def self.write_class_config(yaml_string, clazz)
      begin
        Dir.mkdir("config/skill") unless Dir.exist?("config/skill")
        File.write("config/skill/#{clazz}.yml", yaml_string)
      rescue SystemCallError => e
        raise FileWriteError, "Error writing file: #{e.message}"
      end
    end

    def self.write_class_child_config(yaml_string, clazz)
      begin
        Dir.mkdir("config/skill/children") unless Dir.exist?("config/skill/children")
        File.write("config/skill/children/#{clazz}.yml", yaml_string)
      rescue SystemCallError => e
        raise FileWriteError, "Error writing file: #{e.message}"
      end
    end
  end
end