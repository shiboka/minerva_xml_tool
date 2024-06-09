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

    def self.write_xml(file, doc)
      begin
        File.open(file, "w") { |f| f.write(doc.root.to_xml) }
      rescue Errno::ENOENT => e
        raise FileNotFoundError, "File not found: #{e.message}"
      rescue => e
        raise FileWriteError, "Error writing file: #{e.message}"
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

    def self.write_class_config(yaml_string, clazz, child = false)
      begin
        config_path = ENV["CONFIG"] || "config/"
        if child
          skill_path = File.join(config_path, "skill", "children")
        else
          skill_path = File.join(config_path, "skill")
        end

        Dir.mkdir(skill_path) unless Dir.exist?(skill_path)
        File.write(File.join(skill_path, "#{clazz}.yml"), yaml_string)
      rescue => e
        raise FileWriteError, "Error writing file: #{e.message}"
      end
    end
  end
end