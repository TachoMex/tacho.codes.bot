# frozen_string_literal: true

require 'rake/testtask'
require './lib/services'
require 'kybus/bot/migrator'

Services.configure_services!
task default: :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning = false
  t.pattern = 'test/**/test_*\.rb'
  t.warning = false
end

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    Kybus::Bot::Migrator.run_migrations!(Sequel.connect('mysql2://root:root@db/charrobot'))
  end
end
