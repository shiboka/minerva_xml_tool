module XMLTool
  class MathUtils
    def self.calculate_result(base_value, given_value)
      base = base_value.to_f
      if given_value[/^[\+\-][0-9]+%$/]
        mod = given_value.chop.to_f / 100
        result = base + base * mod
        format("%.4f", result)
      else
        raise ArgumentError, "Invalid value: #{given_value}"
      end
    end
  end
end