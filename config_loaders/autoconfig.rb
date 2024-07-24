# frozen_string_literal: true

require 'kybus/bot'
require 'kybus/configs'

Dir[File.join(__dir__, './models', '*.rb')].each { |file| require file }

require_relative '../bot'

CONF_MANAGER = Kybus::Configuration.auto_load!
APP_CONF = CONF_MANAGER.configs

BOT_ENV = ENV['KYBUS_BOT_ENV'] || 'main'

require_relative 'db'
require_relative 'omegaup'
require_relative 'sqs'

require_relative 'bot_builder'
