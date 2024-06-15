require "nokogiri"
require_relative "../cli/logger"
require_relative "../utils/math_utils"

module XMLTool
  class XMLModifierArea
    def initialize(doc, logger = CLILogger.new)
      raise ArgumentError, 'doc must be a Nokogiri::XML::Document' unless doc.is_a?(Nokogiri::XML::Document)

      @logger = logger
      @doc = doc
    end

    def handle_mob_case(mob, attrs)
      raise ArgumentError, 'mob cannot be nil' unless mob.is_a?(String)
      raise ArgumentError, 'attrs must be a Hash' unless attrs.is_a?(Hash)

      strategies = {
        "small" => -> { change_npc_data(attrs, "size", mob) },
        "medium" => -> { change_npc_data(attrs, "size", mob) },
        "large" => -> { change_npc_data(attrs, "size", mob) },
        "elite" => -> { change_npc_data(attrs, "elite", "true") },
        "all" => -> { handle_id_all_case(attrs) },
        "id" => -> { handle_id_all_case(attrs, mob) }
      }

      strategy = strategies[mob] || strategies["id"]
      strategy.call
    end

    private

    def handle_id_all_case(attrs, mob = nil)
      territory_attr = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      if mob
        change_territory_data(attrs, mob) if territory_attr
        change_npc_data(attrs, "id", mob) if multiple_attrs || !territory_attr
      else
        change_territory_data(attrs) if territory_attr
        change_npc_data(attrs) if multiple_attrs || !territory_attr
      end
    end

    def change_npc_data(attrs, comp = nil, comp_value = nil)
      @doc.css("NpcData Template").find_all { |n| comp ? n[comp] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["id"], node["name"], node.line)
        attrs.each do |attr, value|
          change_npc_attr(node, attr, value)
        end
      end
    end

    def change_territory_data(attrs, comp_value = nil)
      @doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comp_value ? n["npcTemplateId"] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["npcTemplateId"], node["desc"], node.line)
        attrs.each do |attr, value|
          begin
            result = MathUtils.calculate_result(node[attr], value)
          rescue ArgumentError => e
            @logger.log_error_and_exit(e.message)
            return
          end

          change_territory_attr(node, attr, result)
        end
      end
    end

    def change_npc_attr(node, attr, value)
      case attr
      when "maxHp", "atk", "def"
        node.css("Stat").each do |node|
          result = calculate_result(node, attr, value)
          node[attr] = result
          @logger.print_attr(attr, result, value)
        end
      when "str", "res"
        node.css("Critical").each do |node|
          result = calculate_result(node, attr, value)
          node[attr] = result
          @logger.print_attr(attr, result, value)
        end
      end
    end

    def change_territory_attr(node, attr, value)
      if attr == "respawnTime"
        result = calculate_result(node, attr, value)
        node[attr] = result
        @logger.print_attr(attr, result, value)
      end
    end

    def calculate_result(node, attr, value)
      begin
        MathUtils.calculate_result(node[attr], value)
      rescue ArgumentError
        format("%.4f", value)
      end
    end
  end
end