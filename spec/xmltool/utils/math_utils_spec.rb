require "rspec"
require_relative "../../../xmltool/utils/math_utils"

describe XMLTool::MathUtils do
  describe ".calculate_result" do
    context "when the given value is a percentage" do
      it "calculates the result and returns it" do
        expect(XMLTool::MathUtils.calculate_result(100, "+10%")).to eq("110.0000")
      end
    end

    context "when the given value is not a percentage" do
      it "raises an ArgumentError" do
        expect { XMLTool::MathUtils.calculate_result(100, "10") }.to raise_error(ArgumentError)
      end
    end
  end
end
