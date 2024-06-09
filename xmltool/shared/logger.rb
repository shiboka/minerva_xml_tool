require_relative "../logger/cli_logger"

module XMLTool
  class XMLToolLogger
    @logger = CLILogger.new

    def self.logger
      @logger
    end
  end
end