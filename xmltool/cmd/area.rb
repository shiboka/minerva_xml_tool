require_relative "../cli/logger"
require_relative "../shared/sources"
require_relative "../utils/file_utils"
require_relative "../xml/xml_modifier_area"
require_relative "../config/config_loader"
require_relative "../errors"

module XMLTool
  class AreaCommand
    attr_accessor :file_count

    def initialize(areas, mob, logger = CLILogger.new)
      @logger = logger
      @sources = XMLToolSources.sources
      @areas = areas.split("/")
      @mob = mob
      @file_count = 0
    end

    def run(attrs, toggle = true)
      load_config
      run_recursive(attrs, @config, toggle)
      @logger.print_modified_files(@file_count, attrs.count)
    end

    private

    def load_config
      @config = ConfigLoader.load_config(File.join(@sources["config"], "areas.yml"))

      @areas.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          raise AreaNotFoundError, "Area not found: #{a}"
        end
      end

      #@config = { @areas.last => @config}
    end

    def run_recursive(attrs, config, toggle, path = @areas)
      config.each do |key, value|
        new_path = path
        new_path += [key] unless ["server", "client"].include?(key)

        toggle = handle_toggle_and_mode(key, toggle, new_path)
        process_value(value, attrs, toggle, new_path)
      end
    end

    def process_value(value, attrs, toggle, path)
      if value.is_a?(Array)
        value.each { |v| change_attributes(v, attrs) }
      else
        run_recursive(attrs, value, toggle, path)
      end
    end

    def handle_toggle_and_mode(key, toggle, path)
      if ["server", "client"].include?(key)
        if toggle
          toggle = !toggle
          @logger.print_areas(path)
        end

        @mode = key
        @logger.print_mode(key)
      end
      toggle
    end

    def change_attributes(file, attrs)
      path = FileUtils.determine_path(file, @sources, @mode)
    
      if should_print_file(file, attrs)
        @logger.print_file(file, path)
        @file_count += 1
      end
    
      data = FileUtils.read_file(File.join(path, file))
      doc = FileUtils.parse_xml(data)
      xml_modifier = XMLModifierArea.new(doc, @logger)
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