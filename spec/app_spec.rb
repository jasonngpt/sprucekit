require 'spec_helper'

describe SpruceKit do
	before :all do
		@username = configatron.sprucekit.testuser
		@email = configatron.sprucekit.testemail
		user = User.new
		user.username = @username
		user.token = configatron.sprucekit.testtoken
		user.save
	end

	before :each do
		@session = {}
	end

	context "with no username in session" do
		it "should show index page" do
			get '/', {}, 'rack.session' => @session
			expect(last_response).to be_ok
			expect(last_response.body).to match(/is a simple service that will grab a random link/)
		end

		it "should show Pocket login page" do
			get '/login'
			expect(last_response).to be_redirect; follow_redirect!
			expect(last_request.url).to include('getpocket.com')
		end
	end

	context "with a test username in session" do
		before :each do
			@session = { "username" => @username }
		end

		it "should show the test username's /user page" do
			get '/', {}, 'rack.session' => @session
			expect(last_response).to be_redirect; follow_redirect!
			expect(last_request.url).to include('/user')
		end

		it "should show index page if user not found in db" do
			@session = { "username" => "testuser" }
			get '/', {}, 'rack.session' => @session
			expect(last_response).to be_ok
			expect(last_response.body).to match(/is a simple service that will grab a random link/)
		end

		it "should show error page" do
			get '/error', {}, 'rack.session' => @session
			expect(last_response).to be_ok
			expect(last_response).to match(/If the error persists/)
		end
	end

	context "when session does not matter" do
		it "should redirect to root for /unsubscribe" do
			get '/unsubscribe'
			expect(last_response).to be_redirect; follow_redirect!
			expect(last_response.body).to match(/is a simple service that will grab a random link/)		
		end

		it "should show the admin page with the config credentials" do
			authorize configatron.sprucekit.adminuser, configatron.sprucekit.adminpw 
			get '/admin'
			expect(last_response).to be_ok
			expect(last_response.body).to match(/Delete\?/)
		end
		
		it "should return true when trying to send an email for the test user" do
			post '/sendEmails', params = { :username => @username }
			expect(last_response).to be_ok
			expect(last_response).to match(/A random article from your Pocket list has been emailed to you/)
		end

		it "should save the email into the db" do
			post '/saveemail', params = { :username => @username, :email => @email, :mailoptions => @mailoptions }
			expect(last_response).to be_ok
			expect(last_response.body).to match(/Your Pocket access token and email have been saved/)
		end

		it "should delete the user from the db" do
			post '/deluser', params = { :username => @username }
			expect(last_response).to be_ok
			expect(last_response.body).to match(/Your data has been removed from/)
		end
	end

	after :all do
		user = User.find_by(username: @username)
		unless user.nil?
			user.destroy
			user.save
		end
	end
end
