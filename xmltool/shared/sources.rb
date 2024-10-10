module XMLTool
  class XMLToolSources
    @sources = { "server" => "/xmltool/datasheet", "client" => "/xmltool/database", "config" => "/xmltool/config"}

    def self.sources
      @sources
    end
  end
end