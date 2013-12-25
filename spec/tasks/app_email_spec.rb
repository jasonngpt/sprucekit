require 'spec_helper'

app_require 'tasks/app_email'

describe AppEmail do
	before :all do
		@username = configatron.sprucekit.testuser
		user = User.new
		user.username = @username
		user.token = configatron.sprucekit.testtoken
		user.email = configatron.sprucekit.testemail
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
			client = Pocket.client(:access_token => user.token)
			result = client.add :url => 'http://www.sprucekit.com'

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
			client = Pocket.client(:access_token => user.token)
			result = client.retrieve(:state => "archive")

			items = result["list"]

			return if items.empty?

			item = items[items.keys.last]

			readd_result = client.modify([:action => "readd", :item_id => item['item_id']])
			puts readd_result

			if readd_result["status"] == 1
				puts "Unarchive Successful"
			end
		end
	end
end
