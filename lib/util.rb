require 'rest_client'
require 'mandrill'

require_relative '../config/config'

def archiveItem(token,item_id)
	post_data = {"consumer_key" => configatron.pocketspruce.consumer_key, "access_token" => token, "actions" => [ "action" => "archive", "item_id" => item_id ] }

	response = sendPostRequest(configatron.pocket.modify, post_data.to_json)

	result = JSON.parse(response.body)

	if result["status"] == 1
		return "Archive Successful"
	else
		action_results = result["action_results"]
		return action_results.to_s
	end
end

def sendPostRequest(url,post_data)
	response = RestClient.post url, post_data, {:content_type => 'application/json', 'X-Accept' => 'application/json'}

	return response
end

def sendEmail(to,message)
	html_body =		"<html>
						<head>
							<title>#{message['title']}</title>
							<link href='http://fonts.googleapis.com/css?family=Chela+One|Open+Sans' rel='stylesheet' type='text/css' />
							<style> 
								body { 
									font-size: 16px;
									font-family: 'Open Sans', serif;
								}
								h1	{
									font-family: 'Chela One', cursive;
									font-weight: 400;
									font-size: 40px;
								}
								footer { 
									font-size: 10px;
									font-family: 'Open Sans', serif;
								}
							</style>
						</head>
						<body><h1><a href='www.pocketspruce.com'>PocketSpruce</a></h1><p><a href='#{message['url']}'>#{message['title']}</a></p><p>#{message['content']}</p><br /><br /></body>
						<footer>
							<p>
								You are receiving this email as you have signed up at <a href='www.pocketspruce.com'>PocketSpruce</a>. Want to <a href='www.pocketspruce.com/unsubscribe'>Unsubscribe?</a>
							</p>
						</footer>
					</html>"

	begin
		mandrill = Mandrill::API.new configatron.mail.apikey
		message = {		"recipient_metadata"=> ["rcpt"=> to],
						"view_content_link"=>nil,
						"important"=>false,
						"merge"=>true,
						"metadata"=>{"website"=> configatron.pocketspruce.host},
						"return_path_domain"=>nil,
						"signing_domain"=>nil,
						"inline_css"=>nil,
						"subject"=> configatron.mail.subject,
						"google_analytics_domains"=>["pocketspruce.com"],
						"global_merge_vars"=>[{"content"=>"merge1 content", "name"=>"merge1"}],
						"tracking_domain"=>nil,
						"track_opens"=>nil,
						"headers"=>{"Reply-To"=> configatron.mail.from_email},
						#"text"=>"test text",
						"preserve_recipients"=>nil,
						"google_analytics_campaign"=> configatron.mail.from_email,
						"merge_vars"=>[{"rcpt"=> to,
										"vars"=>[{"content"=>"merge2 content", "name"=>"merge2"}]}],
						"auto_text"=>nil,
						"html"=> html_body,
						"from_name"=> configatron.mail.from_name,
						"auto_html"=>nil,
						"to"=> [{"email"=> to,
								#"name"=>"Test Name",
								"type"=>"to"}],
						"subaccount"=>"pocketspruce",
						"tags"=>["daily_item"],
						"url_strip_qs"=>nil,
					    "track_clicks"=>nil,
					    "from_email"=> configatron.mail.from_email}
		async = false
		ip_pool = "Main Pool"

		mandrill_result = mandrill.messages.send message, async, ip_pool
		puts mandrill_result
		return true

	rescue Mandrill::Error => e
		# Mandrill errors are thrown as exceptions
		puts "A mandrill error occurred: #{e.class} - #{e.message}"
		# A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'
		raise
	end
end
