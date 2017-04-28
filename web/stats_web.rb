require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

$LOAD_PATH << File.expand_path('../', __FILE__)
$LOAD_PATH << File.expand_path('../../lib/', __FILE__)

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

require 'active_support/all'
require 'sinatra/base'

require 'data_fetcher'
require 'dashboard_updater'
require 'stats_db'


class StatsWeb < Sinatra::Application
  enable :logging

  get '/' do
    @projects = StatsDb::Project.all
    slim :projects
  end

  get '/:project/punchcards' do |project|
    project = StatsDb::Project.where(name: project).first
    @builds = project.builds
    specs_cases = StatsDb::SpecCase.eager_graph(spec: :project).where(project__id: project.id).all

    @punchcard = {}

    specs_cases.each do |sc|
      @punchcard[sc.description] = Hash[@builds.map do |b|
        [b.id, StatsDb::SpecCaseRun.where(build: b, spec_case: sc).select_map(:status).first]
      end]
    end

    slim :punchcards
  end
end
