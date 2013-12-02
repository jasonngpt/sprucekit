require "json"
require 'readit'

require_relative '../../config/config.rb'
require_relative '../../lib/util.rb'
require_relative '../models/user'

class AppEmail
	def initialize
		@users = User.all
	end

	def appEmailsAll
		@users.each do |a|
			random = rand(configatron.pocketspruce.randomlimit)
			puts "Username #{a.username} : Random: #{random}"

			post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => a.token, "is_article" => "1", "state" => "unread", "count" => random}
			response = sendPostRequest(configatron.pocket.get, post_data)
			
			result = JSON.parse(response.body)

			items = result["list"]

			next if items.empty?

			item = items[items.keys.last]
			puts "#{a.username}: #{item['given_url']}"
			puts "#{a.username}: #{item['resolved_url']}"

			next if ENV['RACK_ENV'] == 'test'

			@parser = Readit::Parser.new configatron.pocketspruce.readapitoken
			response = @parser.parse item['resolved_url']

			to = a.email

			sendEmail(to,response)

			puts archiveItem(a.token, item['item_id'])
		end
	end

	def appUserEmail(username)
		random = rand(configatron.pocketspruce.randomlimit)
		user = User.find_by(username: username)
		puts "Username #{user.username} : Random: #{random}"

		post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => user.token, "is_article" => "1", "state" => "unread", "count" => random}
		response = sendPostRequest(configatron.pocket.get, post_data)

		result = JSON.parse(response.body)

		items = result["list"]

		return false if items.empty?

		item = items[items.keys.last]
		puts "#{user.username}: #{item['given_url']}"
		puts "#{user.username}: #{item['resolved_url']}"

		return true if ENV['RACK_ENV'] == 'test'

		@parser = Readit::Parser.new configatron.pocketspruce.readapitoken
		response = @parser.parse item['resolved_url']

		to = user.email

		sendEmail(to,response)

		puts archiveItem(user.token, item['item_id'])

		return true
	end

	def sendTestEmail(username)
		user = User.find_by(username: username)
		to = user.email
		response = { "title" => "TEST TITLE", "url" => "www.pocketspruce.com/test", "content" => "TEST CONTENT" }

		return true if sendEmail(to,response)
	end

	def archiveTestItem(username)
		user = User.find_by(username: username)

		post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => user.token, "count" => "1"}
		response = sendPostRequest(configatron.pocket.get, post_data)

		result = JSON.parse(response.body)

		items = result["list"]

		return false if items.empty?

		item = items[items.keys.last]

		return true if archiveItem(user.token, item['item_id']) == "Archive Successful"
	end
end
