# frozen_string_literal: true

ENV['OMIBOT_ACTIVE_RECORD__DATABASE'] = 'storage/test.db'

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'rdoc'
require 'webmock/minitest'
require 'mocha/minitest'

require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction
SimpleCov.minimum_coverage 100
SimpleCov.start


require 'kybus/bot/test'
require_relative '../main'

class BotTest < Minitest::Test
  def setup
    super    
    @bot ||= Charrobot::Base.make_test_bot('channel_id' => "test_channel_#{rand(1..1_000_000_000)}",
    'inline_args' => true)
    Charrobot::Base.register(:omega, Omega::Client.new({}))
    DatabaseCleaner.start
    nil
  end

  def teardown
    DatabaseCleaner.clean
  end

  def register_user
    @bot.receives('/iniciar')
    User.last
  end

  def assert_difference(exp)
    initial = eval(exp)
    yield
    refute_equal(initial, eval(exp))
  end
  
  def refute_difference(exp)
    initial = eval(exp)
    yield
    assert_equal(initial, eval(exp))
  end
end

Services.configure_services!
FileUtils.rm_rf(Services.conf['active_record']['database'])
Services.setup_active_record!
Services.run_migrations!
