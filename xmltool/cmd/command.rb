module XMLTool
  class Command
    attr_accessor :logger, :sources

    def initialize(logger = CommandLogger.new)
      @logger = logger
      @sources = { "server" => ENV["DATASHEET"], "client" => ENV["DATABASE"], "config" => ENV["CONFIG"]}
    end
  end
end