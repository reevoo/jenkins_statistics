require 'bundler'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

Bundler.require(:default, :test)

ENV['RACK_ENV'] = 'test'

require 'jenkins_statistics'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
end