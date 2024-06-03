require_relative "../command_logger"

module XMLTool
  class XMLModifierArea
    def initialize(doc, logger = CommandLogger.new)
      @logger = logger
      @doc = doc
    end

    def handle_mob_case(mob, attrs)
      strategies = {
        "small" => -> { change_npc_data("size", mob, attrs) },
        "medium" => -> { change_npc_data("size", mob, attrs) },
        "large" => -> { change_npc_data("size", mob, attrs) },
        "elite" => -> { change_npc_data("elite", "true", attrs) },
        "all" => -> { handle_all_mob_case(attrs) },
        "id" => -> { handle_id_mob_case(mob, attrs) }
      }

      strategy = strategies[@mob] || strategies["id"]
      strategy.call
    end

    private

    def handle_all_mob_case(attrs)
      has_respawn_time = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      change_territory_data(nil, attrs) if has_respawn_time
      change_npc_data(nil, nil, attrs) if multiple_attrs || !has_respawn_time
    end

    def handle_id_mob_case(mob, attrs)
      has_respawn_time = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      change_territory_data(mob, attrs) if has_respawn_time
      change_npc_data("id", mob, attrs) if multiple_attrs || !has_respawn_time
    end

    def change_npc_data(comp, comp_value, attrs)
      @doc.css("NpcData Template").find_all { |n| comp ? n[comp] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["id"], node["name"], node.line)
        attrs.each do |attr, value|
          change_npc_attr(node, attr, value)
        end
      end
    end

    def change_territory_data(comp_value, attrs)
      @doc.css("TerritoryData TerritoryGroup TerritoryList Territory Npc").find_all { |n| comp_value ? n["npcTemplateId"] == comp_value : n }.each do |node|
        @logger.print_id_name_line(node["npcTemplateId"], node["desc"], node.line)
        attrs.each do |attr, value|
          change_territory_attr(node, attr, value)
        end
      end
    end

    def change_npc_attr(node, attr, value)
      case attr
      when "maxHp", "atk", "def"
        node.css("Stat").each do |node|
          node[attr] = value
          @logger.print_attr(attr, value)
        end
      when "str", "res"
        node.css("Critical").each do |node|
          node[attr] = value
          @logger.print_attr(attr, value)
        end
      end
    end

    def change_territory_attr(node, attr, value)
      if attr == "respawnTime"
        node[attr] = value
        @logger.print_attr(attr, value)
      end
    end
  end
end