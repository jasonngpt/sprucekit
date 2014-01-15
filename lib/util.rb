require 'mandrill'
require 'pocket'

require_relative '../config/config'

def archiveItem(token,item_id)
	client = Pocket.client(:access_token => token)
	result = client.modify([:action => "archive", :item_id => item_id])

	if result["status"] == 1
		return "Archive Successful"
	else
		action_results = result["action_results"]
		return action_results.to_s
	end
end

def sendEmail(to,message,mailoption)
	if mailoption == "plaintext"
		html_body = nil
		text_body = "PocketSpruce
						
								#{message['title']}

								#{message['content']}"
	else
						"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
						<html xmlns='http://www.w3.org/1999/xhtml'>
						<head>
							<meta name='viewport' content='width=device-width' />
							<meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
							<title>#{message['title']}</title>
							<link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
							<style> 
								body { 
									font-size: 16px;
									font-family: 'Open Sans', serif;
								}
								h1	{
									font-family: 'Open Sans', serif;
									font-weight: 400;
									font-size: 36px;
								}
								footer { 
									font-size: 10px;
									font-family: 'Open Sans', serif;
								}
							</style>
						</head>
						<body><h1><a href='www.sprucekit.com'>SpruceKit</a></h1><p><a href='#{message['url']}'>#{message['title']}</a></p><p>#{message['content']}</p><br /><br /></body>
						<footer>
							<p>
								You are receiving this email as you have signed up at <a href='www.sprucekit.com'>SpruceKit</a>. Want to <a href='www.sprucekit.com/unsubscribe'>Unsubscribe?</a>
							</p>
						</footer>
					</html>"
	end

	begin
		mandrill = Mandrill::API.new configatron.mail.apikey
		message = {		"recipient_metadata"=> ["rcpt"=> to],
						"view_content_link"=>nil,
						"important"=>false,
						"merge"=>true,
						"metadata"=>{"website"=> configatron.sprucekit.host},
						"return_path_domain"=>nil,
						"signing_domain"=>nil,
						"inline_css"=>nil,
						"subject"=> configatron.mail.subject,
						"google_analytics_domains"=>["sprucekit.com"],
						"global_merge_vars"=>[{"content"=>"merge1 content", "name"=>"merge1"}],
						"tracking_domain"=>nil,
						"track_opens"=>false,
						"headers"=>{"Reply-To"=> configatron.mail.from_email},
						"text"=> text_body,
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
						"subaccount"=>"sprucekit",
						"tags"=>["daily_item"],
						"url_strip_qs"=>nil,
					    "track_clicks"=>false,
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
