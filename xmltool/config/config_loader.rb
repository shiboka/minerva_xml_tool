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

    def self.load_skill_config(child, parent)
      child_data = File.read(child)
      parent_data = File.read(parent)
      data = child_data + "\n" + parent_data

      begin
        Psych.safe_load(data, aliases: true)
      rescue Psych::Exception => e
        raise ConfigLoadError, "Error loading configuration: #{e.message}"
      end
    end
  end
end
