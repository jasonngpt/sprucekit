require 'spec_helper'

app_require 'tasks/app_email'

describe AppEmail do
	before :all do
		@username = configatron.pocketspruce.testuser
		user = User.new
		user.username = @username
		user.token = configatron.pocketspruce.testtoken
		user.email = configatron.pocketspruce.testemail
		user.save
	end

	before :each do
		@appemail = AppEmail.new
	end

	describe "#appUserEmail" do
		it "should return true for test user" do
			@appemail.appUserEmail(@username).should be_true
		end
	end

	describe "#appEmailsAll" do
		it "should return true for all users" do
			@appemail.appEmailsAll.should be_true
		end
	end

	describe "#sendTestEmail" do
		it "should return true for sending test email via mandrill" do
			@appemail.sendTestEmail(@username).should be_true
		end
	end
	
	context "when testing Pocket API" do
		before :each do
			# add an item to pocket list for test user
			user = User.find_by(username: @username)
			post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => user.token, "url" => "http:\/\/www.pocketspruce.com"}
			response = sendPostRequest(configatron.pocket.add, post_data)

			result = JSON.parse(response.body)

			if result["status"] == 1
				puts "Addition Successful"
			end
		end

		describe "#archiveTestItem" do
			it "should return true for archiving test item via pocket api" do
				@appemail.archiveTestItem(@username).should be_true
			end
		end

		after :each do
			# re-add the item back to pocket list for test user
			user = User.find_by(username: @username)
			post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => user.token, "state" => "archive"}
			response = sendPostRequest(configatron.pocket.get, post_data.to_json)

			result = JSON.parse(response.body)

			items = result["list"]

			return if items.empty?

			item = items[items.keys.last]

			readd_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => user.token, "actions" => [ "action" => "readd", "item_id" => item['item_id'] ] }
			readd_response = sendPostRequest(configatron.pocket.modify, readd_data.to_json)

			readd_result = JSON.parse(readd_response.body)

			if readd_result["status"] == 1
				puts "Unarchive Successful"
			end
		end
	end
end
