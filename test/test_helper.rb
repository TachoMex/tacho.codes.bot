# frozen_string_literal: true

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'

SimpleCov.minimum_coverage 100
SimpleCov.start

require 'kybus/bot/test'
require_relative '../bot'

OMEGAUPCLI = Omega::Client.new('user' => 'test', 'pass' => 'pass', 'endpoint' => 'http://localhost')

class BotTest < Minitest::Test
  def setup
    super
    channel_id = "test_channel_#{rand(1..1_000_000_000)}"
    @bot ||= CompetitiveProgrammingBot.make_test_bot('channel_id' => channel_id,
                                                     'inline_args' => true, 'forker' => { 'provider' => 'nofork' })
    @channel_id = "debug_message__#{channel_id}"
    nil
  end

  def stub_omega(method, path, body, response = {})
    stub_request(method, "http://localhost#{path}").with(body:).to_return(status: 200, body: response.to_json)
  end

  def set_contest(contest = 'concurso_test')
    @bot.receives('/iniciar')
    @bot.metadata[:current_contest] = contest
    @bot.metadata[:observe_contest] = { start_time: Time.now.to_i - 100, finish_time: Time.now.to_i + 100 }
    @bot.metadata[:idempotency_token] = 123
    @bot.save_metadata!
    stub_omega(:post, '/api/contest/details/', "contest_alias=#{contest}", alias: contest)
  end
end
