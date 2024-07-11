# frozen_string_literal: true

def run_migrations!
  require 'kybus/bot/migrator'
  Kybus::Bot::Migrator.run_migrations!(APP_CONF['bots']['main']['state_repository'])
end
