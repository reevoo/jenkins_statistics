ENV['RACK_ENV'] ||= 'development'

require 'dotenv'
case ENV['RACK_ENV']
when 'test'
  require 'pry'
  Dotenv.load '.env.test'
when 'development'
  require 'pry'
  Dotenv.load '.env'
else
  Dotenv.load '.env'
end