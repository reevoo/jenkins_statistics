begin
  require 'rspec/core/rake_task'
  
  RSpec::Core::RakeTask.new(:rspec)

  task default: 'rspec'
rescue LoadError
  puts 'RSpec not loaded'
end

task :update_dashboard do
  require_relative 'lib/jenkins_statistics'
  JenkinsStatistics.generate
end