require "rspec/core/rake_task"
require_relative "xmltool/cli/app"
require_relative "xmltool/shared/game_data"

task default: %w[test]

task :config do |t, args|
    XMLTool::GameData.classes.each do |clazz|
      args = ["config", clazz]
      XMLTool::CLIApp.start(args)
    end
end

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = "spec/xmltool/**/*_spec.rb"  # run tests in spec/xmltool
end