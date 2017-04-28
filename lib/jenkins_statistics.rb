require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

$LOAD_PATH << File.expand_path('../', __FILE__)

ENV['RACK_ENV'] ||= 'development'

if %w(development test).include? ENV['RACK_ENV']
  require 'pry'
  require 'dotenv'
  case ENV['RACK_ENV']
  when 'test'
    Dotenv.load '.env.test'
  when 'development'
    Dotenv.load '.env'
  end
end

require 'singleton'
require 'json'
require 'net/http'
require 'active_support/all'

require 'data_fetcher'
require 'dashboard_updater'
require 'stats_db'

Dir.glob(File.join('.', 'lib', 'jobs', '*.rb'), &method(:require))


class JenkinsStatistics
  include Singleton

  def self.run(jobs: [], projects: [])
    instance.run(jobs: jobs, projects: projects)
  end

  def self.lookup(name)
    instance.lookup(name)
  end

  def initialize
    @services = { env: ENV }
    @services[:db] = inject_dependencies(StatsDb.new)
  end

  def run(jobs: [], projects: [])
    jobs.each do |job_name|
      job_class = job_name.to_s.classify.constantize
      inject_dependencies(job_class.new).run(projects: projects)
    end
  end

  def lookup(name)
    name = name.to_sym
    @services[name] = @services[name].call if @services[name].respond_to? :call
    @services[name]
  end

  private

  def inject_dependencies(target)
    return target unless target.respond_to?(:init)
    arguments = target.method(:init).parameters.map do |(_, name)|
      lookup(name)
    end
    target.init(*arguments)
    target
  end
end
