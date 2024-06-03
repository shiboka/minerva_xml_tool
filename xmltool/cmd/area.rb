require "nokogiri"
require_relative "../command_logger"
require_relative "../utils/file_utils"
require_relative "../xml_modifier/xml_modifier_area"
require_relative "../config"
require_relative "../errors"

module XMLTool
  class Area
    attr_reader :file_count

    def initialize(sources, areas, mob)
      @logger = CommandLogger.new
      @sources = sources
      @areas = areas
      @mob = mob
      @file_count = 0
    end

    def load_config(path)
      @config = Config.load_config(path)

      @areas.each do |a|
        if @config.key?(a)
          @config = @config[a]
        else
          raise AreaNotFoundError, "Area not found: #{a}"
        end
      end

      @config = { @areas.last => @config }
    end

    def change_with(attrs)
      traverse_config(@config, attrs)
    end

    private

    def traverse_config(cfg, attrs, areas = [], toggle = true)
      cfg.each do |key, value|
        toggle = handle_toggle(key, toggle, areas)
        handle_mode_and_area(key, areas)
        process_value(value, attrs, areas, toggle)
      end
    end

    def handle_toggle(key, toggle, areas)
      if toggle && (key == "server" || key == "client")
        toggle = !toggle
        @logger.print_areas(areas)
      end
      toggle
    end

    def handle_mode_and_area(key, areas)
      if key == "server" || key == "client"
        @mode = key
        @logger.print_source(key)
      else
        areas.push(key)
      end
    end

    def process_value(value, attrs, areas, toggle)
      if value.is_a?(Array)
        value.each { |v| change_attributes(v, attrs) }
      else
        traverse_config(value, attrs, areas, toggle)
      end
      areas.pop unless @mode
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
    
      File.open(File.join("out/", path, file), "w") { |f| f.write(doc.root.to_xml) }
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