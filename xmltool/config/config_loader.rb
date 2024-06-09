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
        raise FileNotFoundError, "Config file not found: #{path}"
      end
    end

    def self.load_skill_config(child, parent)
      if File.exists?(child) && File.exists?(parent)
        begin
          child_data = File.read(child)
          parent_data = File.read(parent)
          data = child_data + "\n" + parent_data
        rescue => e
          raise FileReadError, "Error reading file: #{e.message}"
        end

        begin
          Psych.safe_load(data, aliases: true)
        rescue Psych::Exception => e
          raise ConfigLoadError, "Error loading configuration: #{e.message}"
        end
      else
        raise FileNotFoundError, "Config files not found"
      end
    end
  end
end
