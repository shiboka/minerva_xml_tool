require "nokogiri"
require_relative "../cli/logger"
require_relative "../utils/math_utils"

module XMLTool
  class XMLModifierSkill
    def initialize(nodes, logger = CLILogger.new)
      @logger = logger
      @nodes = nodes
    end

    def change_skill_data(id, attrs, config_attrs = nil)
      @nodes.find_all { |n| n["id"] == id }.each do |node|
        @logger.print_id_name_line(id, node["name"], node.line)
        
        attrs.each do |attr, value|
          config_attr = config_attrs&.dig(attr)
          
          begin
            result = config_attr ? MathUtils.calculate_result(value, config_attr) : format("%.4f", value)
          rescue ArgumentError => e
            @logger.log_error_and_exit(e.message)
            return
          end

          change_attr(node, attr, result)
          @logger.print_attr(attr, result, config_attrs&.dig(attr))
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
  end
end