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

task :env do
  require_relative './lib/jenkins_statistics'
end

task :test_env do
  ENV['RACK_ENV'] = 'test'
  task(:env).invoke
end

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] => [:env] do |_t, args|
    Sequel.extension :migration
    db = StatsDb::CONNECTION
    db.extension :pg_advisory_locking
    migration_lock_key = 2_053_462_845 * Zlib.crc32(db.get(Sequel.function('current_database')))
    got_lock = db.try_advisory_lock(migration_lock_key) do
      if args[:version]
        puts 'Migrating to version #{args[:version]}'
        Sequel::Migrator.run(db, 'db/migrations', target: args[:version].to_i)
      else
        puts 'Migrating to latest'
        Sequel::Migrator.run(db, 'db/migrations')
      end
      true
    end
    unless got_lock
      $stderr.puts 'Migrations are locked, as another process is currently running them'
      exit 1
    end
  end

  desc 'reset to migration #0 (empty state)'
  task reset: [:env] do
    task('db:migrate').invoke(0)
    puts 'DB reset'
  end

  desc 'reset db and migrate to latest'
  task remigrate: [:env] do
    task('db:reset').invoke
    task('db:migrate').reenable
    task('db:migrate').invoke
  end
end
