
require "nokogiri"
require_relative "../shared/logger"

module XMLTool
  class XMLModifierStats
    def initialize(nodes)
      @logger = XMLToolLogger.logger
      @nodes = nodes
    end

    def change_stats_data(clazz, race, attrs)
      if race == "all"
        nodes_filtered = @nodes.find_all { |n| n["class"] == clazz }
      else
        nodes_filtered = @nodes.find_all { |n| n["class"] == clazz && n["race"] == race }
      end

      nodes_filtered.each do |node|
        @logger.print_class_race_gender_line(clazz.capitalize, node["race"].capitalize, node["gender"].capitalize, node.line)

        attrs.each do |attr, value|
          change_attr(node, attr, value)
          @logger.print_attr(attr, value)
        end
      end
    end

    private

    def change_attr(node, attr, value)
      case attr
      when "maxMp"
        node.css("StatByLevelTable StatByLevel").each do |node|
          node[attr] = value
        end
      when "managementType", "tickCycle", "effectValue", "decayStartTime", "decayStartTimeMpFull", "recoveryStartTime"
        node.css("ManaPoint").each do |node|
          node[attr] = value
        end
      end
    end 
  end
end
