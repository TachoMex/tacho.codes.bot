# frozen_string_literal: true

require './main'

def lambda_handler(event:, context:)
  secret_token = ENV.fetch('SECRET_TOKEN', nil)
  header_token = event.dig('headers', 'x-telegram-bot-api-secret-token')

  return { statusCode: 403, body: JSON.generate('Forbidden') } unless header_token == secret_token

  body = JSON.parse(event['body'])

  BOT.handle_message(body)
  { statusCode: 200, body: '' }
end

def sqs_job_handler(event:, context: nil)
  event['Records'].each do |record|
    json = JSON.parse(record['body'], symbolize_names: true)
    BOT.handle_job(json[:job], json[:args], json.dig(:state, :data, :channel_id))
  end
  { statusCode: 200, body: '' }
rescue StanrdardError => e
  BOT.log_fatal('Unhandled error', message: e.message, trace: e.backtrace)
end
