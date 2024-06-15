#require_relative "xmltool/cli/app"
#XMLTool::CLIApp.start(ARGV)

require_relative "xmltool/web/app"
XMLTool::WebApp.run!
