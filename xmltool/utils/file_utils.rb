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
  end
end