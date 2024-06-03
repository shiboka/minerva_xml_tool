module XMLTool
  class FileNotFoundError < StandardError; end
  class FileReadError < StandardError; end
  class AreaNotFoundError < StandardError; end
  class XmlParseError < StandardError; end
  class ConfigLoadError < StandardError; end
  class FileWriteError < StandardError; end
end