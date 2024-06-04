require_relative "../command_logger"

module XMLTool
  class XMLModifierArea
    def initialize(doc, logger = CommandLogger.new)
      @logger = logger
      @doc = doc
    end

    def handle_mob_case(mob, attrs)
      strategies = {
        "small" => -> { change_npc_data(attrs, "size", mob) },
        "medium" => -> { change_npc_data(attrs, "size", mob) },
        "large" => -> { change_npc_data(attrs, "size", mob) },
        "elite" => -> { change_npc_data(attrs, "elite", "true") },
        "all" => -> { handle_all_mob_case(attrs) },
        "id" => -> { handle_id_mob_case(attrs, mob) }
      }

      strategy = strategies[mob] || strategies["id"]
      strategy.call
    end

    private

    def handle_all_mob_case(attrs)
      has_respawn_time = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      change_territory_data(attrs) if has_respawn_time
      change_npc_data(attrs) if multiple_attrs || !has_respawn_time
    end

    def handle_id_mob_case(attrs, mob)
      has_respawn_time = attrs.key? "respawnTime"
      multiple_attrs = attrs.length > 1

      change_territory_data(attrs, mob) if has_respawn_time
      change_npc_data(attrs, "id", mob) if multiple_attrs || !has_respawn_time
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