require 'nokogiri'
require 'open-uri'
require 'colorize'
require_relative "../cli/logger"
require_relative "../shared/sources"
require_relative "../xml/xml_modifier_stats"

module XMLTool
  class StatsCommand
    def initialize(clazz, race, logger = CLILogger.new)
      @logger = logger
      @sources = XMLToolSources.sources
      @clazz = clazz
      @race = race
    end

    def run(attrs)
      begin
        file = File.join(@sources["server"], "UserData.xml")
        process_file(file, attrs)
        @logger.print_modified_files(1, attrs.count)
      rescue TypeError => e
        @logger.log_error_and_exit(e.message)
      end
    end

    private

    def process_file(file, attrs)
      @logger.print_file(file)

      begin
        data = FileUtils.read_file(file)
        doc = FileUtils.parse_xml(data)
      rescue FileNotFoundError, FileReadError, XmlParseError => e
        @logger.log_error_and_exit(e.message)
      end

      nodes = doc.css('UserData Template')
      xml_modifier = XMLModifierStats.new(nodes, @logger)
      xml_modifier.change_stats_data(@clazz, @race, attrs)

      begin
        FileUtils.write_xml(file, doc)
      rescue FileWriteError => e
        @logger.log_error_and_exit(e.message)
      end
    end
  end
end
