require "rspec"
require_relative "../../../xmltool/utils/attr_utils"

describe XMLTool::AttrUtils do
  describe ".parse_attrs" do
    context "when the attributes are not empty" do
      it "parses the attributes and returns them as a hash" do
        expect(XMLTool::AttrUtils.parse_attrs(["attr1=value1", "attr2=value2"])).to eq({ "attr1" => "value1", "attr2" => "value2" })
      end
    end

    context "when the attributes are empty" do
      it "returns an empty hash" do
        expect(XMLTool::AttrUtils.parse_attrs([])).to eq({})
      end
    end
  end
end