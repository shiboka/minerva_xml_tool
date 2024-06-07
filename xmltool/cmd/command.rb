require_relative "../cli_logger"

module XMLTool
  class Command
    attr_accessor :logger, :sources

    def initialize(logger = CLILogger.new)
      @logger = logger
      @sources = { "server" => ENV["DATASHEET"], "client" => ENV["DATABASE"], "config" => ENV["CONFIG"]}
    end
  end
end