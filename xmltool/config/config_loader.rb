require "psych"
require_relative "../errors"

module XMLTool
  class ConfigLoader
    def self.load_config(path)
      if File.exists?(path)
        begin
          Psych.load_file(path)
        rescue Psych::Exception => e
          raise ConfigLoadError, "Error loading configuration: #{e.message}"
        end
      else
        raise ConfigLoadError, "Config file not found: #{path}"
      end
    end
  end
end
