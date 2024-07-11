# frozen_string_literal: true

::Kybus::Bot::Forkers::LambdaSQSForker.register_queue_client(SQS)
BOT = CompetitiveProgrammingBot.new(APP_CONF['bots']['main'])
