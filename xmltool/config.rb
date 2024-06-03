module XMLTool
  class Config
    class ConfigLoadError < StandardError; end

    def self.load_config(path)
      begin
        Psych.load_file(path)
      rescue Psych::Exception => e
        raise ConfigLoadError, "Error loading configuration: #{e.message}"
      end
    end
  end
end