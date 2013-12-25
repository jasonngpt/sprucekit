require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'rack-google-analytics'
require 'json'
require 'pocket'

require_relative "config/config"
require_relative "lib/util"
require_relative "app/models/user"
require_relative "app/tasks/app_email"

class SpruceKit < Sinatra::Base

	configure :production do
		use Rack::GoogleAnalytics, :tracker => configatron.sprucekit.analytics
	end

	Pocket.configure do |config|
		config.consumer_key = configatron.sprucekit.consumer_key
	end

	configure do
		set :database_file, "config/database.yml"
		set :views, "app/views"

		enable :sessions unless test?
		set :session_secret, "sprucekit"

		enable :logging

		register Sinatra::Flash
	end

	before {
		# Setup logging
		Dir.mkdir('log') unless File.exist?('log')
		env["rack.logger"] = Logger.new "#{settings.root}/log/#{settings.environment}.log" 
	}

	helpers do
		def protected!
			return if authorized?
			headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
			halt 401, "Not authorized\n"
		end

		def authorized?
			@auth ||= Rack::Auth::Basic::Request.new(request.env)
			@auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [configatron.sprucekit.adminuser, configatron.sprucekit.adminpw]
		end
	end

	get '/' do
		if User.find_by(username: session["username"])
			logger.info "[LOGIN] #{session['username']}"
			flash.next[:notice] = "Welcome back, #{session['username']}!"
			redirect "/user"
		else
			erb :index
		end
	end

	get '/unsubscribe' do
		redirect "/"
	end

	get '/login' do
		session[:code] = Pocket.get_code(:redirect_uri => configatron.sprucekit.auth)
		redirect_url = Pocket.authorize_url(:code => session[:code], :redirect_uri => configatron.sprucekit.auth)

		redirect redirect_url
	end

	get '/user' do
		user = User.find_by(username: session["username"])
		if user.nil?
			flash.next[:notice] = "Please login again."
			redirect "/"
		else
			@username = session["username"]
			@email = user.email
		end

		erb :user
	end

	get '/auth' do
		result = Pocket.get_result(session[:code], :redirect_uri => configatron.sprucekit.auth)
		@username = result["username"]
		access_token = result['access_token']
		session["username"] = @username

		user = User.find_by(username: @username)

		if user.nil?
			logger.info "[CREATE] #{@username} in db with token"
			newuser = User.new
			newuser.username = @username
			newuser.token = access_token
			if newuser.save
				flash.next[:notice] = "Login successful!"
				redirect "/user"
			else
				flash.next[:error] = "Login failed. Please try again."
				redirect "/"
			end
		else
			logger.info "[UPDATE] #{@username} token"
			user.token = access_token
			if user.save
				flash.next[:notice] = "Login successful!"
				redirect "/user"
			else
				flash.next[:error] = "Login failed. Please try again."
				redirect "/"
			end
		end
	end

	post '/saveemail' do
		@username = params[:username]
		@email = params[:email]

		user = User.find_by(username: @username)

		if user.nil?
			flash.next[:error] = "Please login again."
			logger.error "[Error] User not found in db. Redirect to main page."
			redirect "/"
		else
			logger.info "[UPDATE] #{@username} email"
			user.email = @email
			user.save
		end

		erb :completed
	end

	post '/deluser' do
		@username = params[:username]

		user = User.find_by(username: @username)

		if user.nil?
			logger.error "[ERROR] #{@username} not found to be deleted"
			redirect "/"
		else
			user.destroy
			user.save
			logger.info "[DELETE] #{@username} removed from db"
			session["username"] = nil
		end

		erb :deleteuser
	end

	post '/sendEmails' do
		@username = params[:username]

		if AppEmail.new.appUserEmail(@username)
			flash.now[:notice] = "Email sent!"
			erb :emailsent
		else
			flash.next[:error] = "Something went wrong in the sending of the email. Please try again."
			redirect "/error"
		end
	end

	get '/admin' do
		protected!

		@users = User.all

		erb :admin
	end

	get '/error' do
		@username = session["username"]

		erb :error
	end
end

