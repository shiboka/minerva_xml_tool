module XMLTool
  class XMLToolSources
    @sources = { "server" => ENV["DATASHEET"], "client" => ENV["DATABASE"], "config" => ENV["CONFIG"]}

    def self.sources
      @sources
    end
  end
end