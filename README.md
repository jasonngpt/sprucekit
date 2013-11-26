##PocketSpruce

A companion tool for Pocket (getpocket.com) with the features below:

- Send a random article from your Pocket list to your email and archive it
- Remove away dead links (404 links) (Pending)
- Sieve out duplicate links (Pending)
- Resolve redirected links and save the final link (Pending)

Tools and API Used:

- Sinatra
- Pocket API to authenticate and get/add/remove items
- Readability API to extract content of the article
- Mandrill API to send emails
- Postgresql for the data store


# Installation

```sh
	git clone
	cd pocketspruce
	bundle install
	# Add in own config in the Config file
	# the app.host in configatron.pocketspruce has to be set
	vi config/config.rb
	# Prepare the database i.e. Dev or Prod
	vi config/database.yml
	bundle exec rake db:migrate
	# Start the app with the RACK server of choice i.e. using Shotgun here
	shotgun config.ru

	# Setup cronjob for the sendDailyEmail rake task

	# There is an admin panel to administer the users with basic auth at <app>/admin
```
