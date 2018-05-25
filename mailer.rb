require 'sinatra'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'sinatra/jsonp'
require 'active_support'
require 'active_support/core_ext/object/blank.rb'
require 'action_mailer'
require 'uri'
require 'base64'
require 'yaml'
require 'haml'
require 'cgi'

enable :sessions

configure do
  set :server, :puma
  set :port, 9494
  enable :cross_origin
end

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.view_paths = File.expand_path('views')

class Mailer < ActionMailer::Base
  default from: 'paul@savvysoftworks.com'
  layout false

  def notification(form_data, account_info)

    @form_data = form_data
    @time = Time.now.getutc

    mail(to: account_info[:to],
         subject: "New message from #{account_info[:website]}",
         template_path: 'mailer',
         template_name: 'notification',
         content_type: 'text/html'
         )
  end
end

accounts = YAML.load_file('accounts.yaml').deep_symbolize_keys!

post '/' do
  public_token = params['public_token'].to_sym
  account_configuration = accounts[public_token]

  redirect '/error' unless account_configuration

  # redirect account_configuration[:account][:after_failure]

  ActionMailer::Base.smtp_settings = account_configuration[:smtp]

  if params['verify'].nil? || params['verify'].empty?
    Mailer.notification(params, account_configuration[:account]).deliver_now
  end

  after_success = params.fetch("after_success", account_configuration[:account][:after_success])
  redirect after_success
end

get '/' do
  payloadStr = Base64.decode64(params['payload'])
  payload = CGI::parse payloadStr
  public_token = payload['public_token'].first.to_sym
  account_configuration = accounts[public_token]

  ActionMailer::Base.smtp_settings = account_configuration[:smtp]

  Mailer.notification(payload, account_configuration[:account]).deliver_now
  jsonp [{success: 'Message Sent'}], params['callback']
end

get '/error' do
  haml :error
end
