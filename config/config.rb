require 'configatron'
require 'active_support/core_ext/integer/inflections'

configatron.pocket do |pocket|
	pocket.url = 'https://getpocket.com'
	pocket.request = pocket.url + '/v3/oauth/request'
	pocket.auth = pocket.url + '/v3/oauth/authorize'
	pocket.get = pocket.url + '/v3/get'
	pocket.add = pocket.url + '/v3/add'
	pocket.modify = pocket.url + '/v3/send'
end

configatron.pocketspruce do |app|
	app.analytics = '<insert_google_analytics_id>'
	app.host = '<insert_host_url e.g. http://localhost:9393>'
	app.login = app.host + '/login'
	app.auth = app.host + '/auth'
	app.consumer_key = '<insert_consumer_key_from_Pocket>'
	app.randomlimit = 100
	app.readapitoken = '<insert_Readability_parser_api_key>'
	app.adminuser = 'admin'
	app.adminpw = 'admin'
	app.testuser = '<insert_test_user>'
	app.testemail = '<insert_test_email>'
	app.testtoken = '<insert_test_token>'
end

configatron.mail do |mail|
	mail.apikey = '<insert_api_key_from_mandrill>'
	mail.from_email = '<insert_from_address>'
	mail.from_name = '<insert_from_name>'
	mail.date = Time.new.strftime("#{Time.new.day.ordinalize} %B %Y")
	mail.subject = "Pocketspruce for " + mail.date
end
