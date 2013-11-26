require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"

Bundler.require

require "./app"
require_relative "./app/tasks/app_email"

desc "Send Daily Email of Random Item from Pocket to all users"
task :sendDailyEmail do
	AppEmail.new.appEmailsAll
end
