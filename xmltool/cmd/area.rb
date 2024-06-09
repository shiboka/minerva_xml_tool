require_relative "../shared/logger"
require_relative "../shared/sources"
require_relative "../utils/file_utils"
require_relative "../xml/xml_modifier_area"
require_relative "../config/config_loader"
require_relative "../errors"

module XMLTool
  class Area
    attr_accessor :file_count

    def initialize(areas, mob)
      @logger = XMLToolLogger.logger
      @sources = XMLToolSources.sources
      @areas = areas
      @mob = mob
      @file_count = 0
    end

    def load_config(path)
      @config = ConfigLoader.load_config(path)

      @areas.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          raise AreaNotFoundError, "Area not found: #{a}"
        end
      end

      @config = { @areas.last => @config }
    end

    def change_with(attrs, config = @config, toggle = true)
      config.each do |key, value|
        toggle = handle_toggle(key, toggle)
        handle_mode_and_area(key)
        process_value(value, attrs, toggle)
      end
    end

    private

    def handle_toggle(key, toggle)
      if toggle && (key == "server" || key == "client")
        toggle = !toggle
        @logger.print_areas(@areas)
      end
      toggle
    end

    def handle_mode_and_area(key)
      if key == "server" || key == "client"
        @mode = key
        @logger.print_mode(key)
      else
        @areas.push(key)
      end
    end

    def process_value(value, attrs, toggle)
      if value.is_a?(Array)
        value.each { |v| change_attributes(v, attrs) }
      else
        change_with(attrs, value, toggle)
      end
      @areas.pop unless @mode
    end

    def change_attributes(file, attrs)
      path = FileUtils.determine_path(file, @sources, @mode)
    
      if should_print_file(file, attrs)
        @logger.print_file(file, path)
        @file_count += 1
      end
    
      data = FileUtils.read_file(File.join(path, file))
      doc = FileUtils.parse_xml(data)
      xml_modifier = XMLModifierArea.new(doc)
      xml_modifier.handle_mob_case(@mob, attrs)
    

      begin
        FileUtils.write_xml(File.join(path, file), doc)
      rescue FileWriteError => e
        @logger.log_error_and_exit(e.message)
      end
    end

    def should_print_file(file, attrs)
      if file[/^NpcData/] && %w[maxHp atk def str res].any? { |key| attrs.key?(key) }
        true
      elsif file[/^TerritoryData/] && attrs.key?("respawnTime")
        true
      end
    end
  end
end