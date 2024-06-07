require_relative "../cli_logger"

module XMLTool
  class XMLModifier
    attr_accessor :logger

    def initialize(logger = CLILogger.new)
      @logger = logger
    end
  end
end