require "json"
require 'pocket'

require_relative '../../config/config.rb'
require_relative '../../lib/util.rb'
require_relative '../models/user'

class AppEmail
	def initialize
		@users = User.all
	end

	def appEmailsAll
		@users.each do |a|
			random = rand(configatron.sprucekit.randomlimit)
			puts "Username #{a.username} : Random: #{random}"

			client = Pocket.client(:access_token => a.token)
			begin
				response = client.retrieve(:detailType => :complete, :count => random, :is_article => 1)
			rescue Pocket::Error
				puts "Username #{a.username} has a Pocket User Error i.e. access_token invalid"
				# TODO: split into deeper exceptions
				# TODO: possible to send user an email to re-login to get the access_token again?
				next
			end

			items = response["list"]

			next if items.empty?

			item = items[items.keys.last]
			puts "#{a.username}: #{item['given_url']}"
			puts "#{a.username}: #{item['resolved_url']}"

			next if ENV['RACK_ENV'] == 'test'

			@parser = Readit::Parser.new configatron.sprucekit.readapitoken
			response = @parser.parse item['resolved_url']

			to = a.email

			sendEmail(to,response)

			puts archiveItem(a.token, item['item_id'])
		end
	end

	def appUserEmail(username)
		random = rand(configatron.sprucekit.randomlimit)
		user = User.find_by(username: username)
		puts "Username #{user.username} : Random: #{random}"

		client = Pocket.client(:access_token => user.token)
		response = client.retrieve(:detailType => :complete, :count => random, :is_article => 1)

		items = response["list"]

		return false if items.empty?

		item = items[items.keys.last]
		puts "#{user.username}: #{item['given_url']}"
		puts "#{user.username}: #{item['resolved_url']}"

		return true if ENV['RACK_ENV'] == 'test'

		@parser = Readit::Parser.new configatron.sprucekit.readapitoken
		response = @parser.parse item['resolved_url']

		to = user.email
		mailoption = user.mailoptions

		sendEmail(to,response,mailoption)

		puts archiveItem(user.token, item['item_id'])

		return true
	end

	def sendTestEmail(username)
		user = User.find_by(username: username)
		to = user.email
		mailoption = user.mailoptions
		response = { "title" => "TEST TITLE", "url" => "www.sprucekit.com/test", "content" => "TEST CONTENT" }

		return true if sendEmail(to,response,mailoption)
	end

	def archiveTestItem(username)
		user = User.find_by(username: username)

		client = Pocket.client(:access_token => user.token)
		response = client.retrieve(:detailType => :complete, :count => 1)

		items = response["list"]

		return false if items.empty?

		item = items[items.keys.last]

		return true if archiveItem(user.token, item['item_id']) == "Archive Successful"
	end
end
