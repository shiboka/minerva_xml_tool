require "psych"
require_relative "errors"

module XMLTool
  class Config
    def self.load_config(path)
      begin
        Psych.load_file(path)
      rescue Psych::Exception => e
        raise ConfigLoadError, "Error loading configuration: #{e.message}"
      end
    end
  end
end