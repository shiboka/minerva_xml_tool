require "rspec/core/rake_task"

task default: %w[test]

task :config do |t, args|
  classes = ["Warrior", "Berserker", "Slayer", "Archer", "Sorcerer", "Lancer", "Priest", "Elementalist", "Soulless", "Engineer", "Assassin", "Fighter", "Glaiver"]
    classes.each do |clazz|
      sh "ruby xmltool.rb config #{clazz}"
    end
end

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = "spec/xmltool/**/*_spec.rb"  # run tests in spec/xmltool
end