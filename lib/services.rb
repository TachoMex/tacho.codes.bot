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

require_relative '../db/models/user'
require_relative '../db/models/user_contest_relationship'
require_relative '../db/models/channel'
require_relative '../db/models/contest'

module Services
  class << self
    attr_reader :conf, :conf_manager, :services

    def configure_services!
      Dir.mkdir('storage') unless Dir.exist?('storage')
      @conf_manager = Kybus::Configuration.auto_load!
      @conf = @conf_manager.configs
      @services = @conf_manager.all_services
    end

    def setup_active_record!
      ActiveRecord::Base.establish_connection(@conf['active_record'])
    end

    # :nocov:
    def omega
      @omega ||= begin
        omega = Omega::Client.new(@conf['omega'])
        omega.login
        omega
      end
    end

    def bot
      @bot ||= begin
        bot = Charrobot::Base.new(Services.conf['bots']['main'])
        Charrobot::Base.register(:omega, omega)
        bot
      end
    end
    # :nocov:

    def run_migrations!
      require 'active_record/tasks/database_tasks'
      require 'kybus/bot/migrator'
      Kybus::Bot::Migrator.run_migrations!(Services.bot_database)
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    def bot_database
      @bot_database ||= Sequel.connect(Services.conf['bots']['main']['state_repository']['endpoint'])
    end
  end
end
