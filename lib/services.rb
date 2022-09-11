# frozen_string_literal: true

require 'kybus/bot'
require 'kybus/configs'
require './bot/base'
require './bot/commands'
require 'active_record'
require 'sequel'
require 'omega'
require 'amazing_print'
require 'telegram/bot'
# require './lib/models/migrations/001_create_reminders_table'

module Services
  class << self
    attr_reader :conf, :conf_manager, :services

    def configure_services!
      Dir.mkdir('storage') unless Dir.exist?('storage')
      @conf_manager = Kybus::Configuration.auto_load!
      @conf = @conf_manager.configs
      @services = @conf_manager.all_services
      ActiveRecord::Base.establish_connection(@conf['database'])
    end

    def omega
      @omega ||= Omega::Client.new(@conf['omega'])
    end

    def bot
      @bot ||= begin
        bot = Charrobot::Base.new(Services.conf['bots']['main'])
        Charrobot::Commands.bot_register(bot)
        # bot.register(:feature_flags, :clarifications, Services.conf['omega'].fetch('clars', true))
        bot
      end
    end
  end
end
