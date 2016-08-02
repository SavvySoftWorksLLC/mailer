# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class MyTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_mailer
    post '/', {name: 'butt',
               email: 'butt@tp.com',
               textarea: 'hi smelly',
               action: 'value'}

    assert last_response.ok?
    delivered_email = ActionMailer::Base.deliveries.last
    assert_includes delivered_email.to, 'paul@savvysoftworks.com'
    assert_includes delivered_email.body, 'hi smelly'
    assert_includes delivered_email.subject, 'butt@tp.com'
  end
end