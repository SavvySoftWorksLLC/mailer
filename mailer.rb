require 'sinatra'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'sinatra/jsonp'
require 'active_support'
require 'active_support/core_ext/object/blank.rb'
require 'action_mailer'
require 'uri'
require 'base64'

enable :sessions

set :port, 9494

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   # :address        => "smtp.gmail.com",
   # :port           => 587,
   # :domain         => "example.com",
   # :authentication => :plain,
   # :user_name      => "YOUR_EMAIL",
   # :password       => "YOUR_PASSWORD",
   # :enable_starttls_auto => true

  :address => "localhost", :port => 1025

  }

ActionMailer::Base.view_paths = File.expand_path('views')

class Mailer < ActionMailer::Base
  default from: 'paul@savvysoftworks.com'
  layout false

  def notification(form_data)

    @form_data = form_data
    @time = Time.now.getutc

    mail(to: 'paul@savvysoftworks.com',
         subject: "New message from #{@form_data['email']}",
         template_path: 'mailer',
         template_name: 'notification')
  end
end

configure do
  enable :cross_origin
end

post '/' do
  Mailer.notification(params).deliver

  # redirect 'http://localhost:4567/#contact'
end

get '/' do
  payloadStr = Base64.decode64(params['payload'])
  puts payloadStr

  payload = Rack::Utils.parse_nested_query payloadStr
  puts payload.inspect

  Mailer.notification(payload)
  jsonp [{success: 'Message Sent'}], params['callback']
end
