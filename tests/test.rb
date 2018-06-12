# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class MyTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    app = Sinatra::Application
    app.set :accounts, YAML.load_file('example.accounts.yaml').deep_symbolize_keys!
    app
  end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_mailer
    post '/', { public_token: 'default',
                name: 'butt',
                email: 'butt@tp.com',
                verify: '',
                action: 'value' }

    assert last_response.ok?
    delivered_email = ActionMailer::Base.deliveries.last
    assert_includes delivered_email.to, 'paul@savvysoftworks.com'
    assert_includes delivered_email.body, 'hi smelly'
    assert_includes delivered_email.subject, 'butt@tp.com'
  end

  def test_mailer_redirects_to_error_without_configured_account
    post '/', { name: 'butt',
                email: 'butt@tp.com',
                verify: '',
                action: 'value' }

    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'Account Not Configured'
  end

  def test_mailer_redirects_to_error_without_valid_configured_account
    post '/', { public_token: 'no-account',
                name: 'butt',
                email: 'butt@tp.com',
                verify: '',
                action: 'value' }

    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'Account Not Configured'
  end
end
