# frozen_string_literal: true

if APP_CONF.to_h.dig('bots', BOT_ENV, 'provider', 'forker', 'provider') == 'sqs'
  require 'aws-sdk-sqs'

  SQS = Aws::SQS::Client.new
else
  SQS = nil
end
