begin
  require 'rspec/core/rake_task'
  require 'reevoocop/rake_task'
  RSpec::Core::RakeTask.new(:rspec)
  ReevooCop::RakeTask.new(:reevoocop)

  task default: [:rspec, :reevoocop]
rescue LoadError
  puts 'RSpec not loaded'
end


task :update_dashboard do
  sh 'bin/jenkins_statistics'
end
