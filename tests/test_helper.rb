# test_helper.rb
ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'byebug'

require File.expand_path '../../mailer.rb', __FILE__