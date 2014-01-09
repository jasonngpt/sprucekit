ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'sinatra'
require 'bundler'

Bundler.require

require './app'

def app_require(file)
	require File.expand_path(File.join('app', file))
end

# setup test environment
#set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
set :database_file, "../config/database.yml"

def app
	SpruceKit
end

RSpec.configure do |conf|
	conf.include Rack::Test::Methods
end
