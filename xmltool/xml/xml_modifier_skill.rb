require_relative "../command_logger"

module XMLTool
  class XMLModifierSkill
    def initialize(nodes, logger = CommandLogger.new)
      @logger = logger
      @nodes = nodes
    end

    def change_skill_data(id, attrs, config_attrs = nil)
      @nodes.find_all { |n| n["id"] == id }.each do |node|
        @logger.print_id_name_line(id, node["name"], node.line)
        
        attrs.each do |attr, value|
          result = calculate_result(value, config_attrs&.dig(attr))
          change_attr(node, attr, result)

          @logger.print_skill_attr(attr, result, config_attrs&.dig(attr))
        end
      end
    end

    private

    def change_attr(node, attr, value)
      case attr
      when "mp", "hp", "anger"
        node.css("Precondition Cost").each do |node|
          node[attr] = value
        end
      when "coolTime"
        node.css("Precondition").each do |node|
          node[attr] = value
        end
      when "frontCancelEndTime", "rearCancelStartTime", "moveCancelStartTime"
        node.css("Action Cancel").each do |node|
          node[attr] = value
        end
      when "totalAtk", "timeRate", "attackRange"
        node[attr] = value
      end
    end

    def calculate_result(base_value, config_value)
      base = base_value.to_f
      if config_value
        mod = config_value.to_f
        base + base * mod
      else
        base
      end
    end
  end
end