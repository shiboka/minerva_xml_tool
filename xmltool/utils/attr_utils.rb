module XMLTool
  class AttrUtils
    def self.parse_attrs(attrs)
      attrs_hash = {}
      attrs.each do |attr|
        attr_split = attr.split("=")
        attrs_hash[attr_split[0]] = attr_split[1]
      end
      attrs_hash
    end
  end

end