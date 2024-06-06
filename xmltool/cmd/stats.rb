require 'nokogiri'
require 'open-uri'
require 'colorize'
require_relative "command"
require_relative "../xml/xml_modifier_stats"
require_relative "../command_logger"

module XMLTool
  class Stats < Command
    def initialize(clazz, race)
      super()
      @logger = logger
      @sources = sources
      @clazz = clazz
      @race = race
    end

    def change_with(attrs)
      file = File.join(@sources["server"], "UserData.xml")
      process_file(file, attrs)
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
      xml_modifier = XMLModifierStats.new(nodes)
      xml_modifier.change_stats_data(@clazz, @race, attrs)

      begin
        FileUtils.write_xml(file, doc)
      rescue FileWriteError => e
        @logger.log_error_and_exit(e.message)
      end
    end
  end
end
