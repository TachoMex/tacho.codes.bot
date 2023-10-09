require 'kybus/bot'

require_relative 'commands/user_commands'
require_relative 'commands/contests_commands'

module Charrobot
  class Base < Kybus::Bot::Base
    extend Kybus::DRY::ResourceInjector

    class BotNotInitialized < StandardError
    end

    def initialize(*args)
      super

      rescue_from(BotNotInitialized) do
        redirect('/help')
      end

      rescue_from(StandardError) do
        # :nocov:
        log_error('Unexpected error in bot', error: params[:_last_exception], trace: params[:_last_exception].backtrace)
        send_message('Error inesperado')
        # :nocov:
      end

      register_command('default') do
        redirect('/help')
      end

      UserCommands.register_commands(self)
      ContestsCommands.register_commands(self)
    end

    helpers do
      def bot_started?
        user = current_user
        !!user
      end

      def current_user
        Channel.find_by(channel_id: current_channel)&.user
      end

      def current_user!
        user = current_user
        raise BotNotInitialized if user.nil?

        user
      end

      def ensure_admin
        user = current_user
        if user.admin
          yield
        else
          log_warn('User is trying to perform an admin operation', user: user.id, channel: current_channel)
        end
      end

      def provider_name
        provider.class.name.split('::').last.downcase
      end

      def omega
        @omega ||= Charrobot::Base.resource(:omega)
      end

      # :nocov:
      def master_channel
        @master_channel ||= Services.conf['bots']['main']['channels']['master']
      end

      def contests
        @contest ||= Services.conf['omega']['contests'].map { |name| omega.contest(name) }
      end

      def respond_clarif(message, response)
        message_id = message.match(/reply_id: \d*/).to_s.gsub('reply_id: ', '')
        return if message_id.empty?

        omega.respond_clarif(message_id, response)

        send_message("Respondiendo a #{message_id}:\n#{response}", master_channel)
      end

      def clarif_to_message(question, answered = false)
        msg = "Open Clarification :: #{question[:contest_alias]} >> \n " \
        "#{question[:problem_alias]}\n" \
        "#{question[:message]}\n" \
        "reply_id: #{question[:clarification_id]}"
        msg += "\nAnswer: #{question[:answer]}" if answered
        msg
      end

      def open_clars
        contests.each do |contest|
          contest.clarifications
                 .each { |clar| send_message(clarif_to_message(clar, true), master_channel) }
        end
      end

      def find_contest(name)
        omega.contest(name)
      end

      def observe_contest
        puts "Authorized Channel: #{master_channel}"
        score_notif = proc do |_name, user, problem, points, last_score, contest_name|
          msg = "#{contest_name}>>\n#{user} solved #{problem} with #{points} (+#{points - last_score})"
          send_message(msg, master_channel)
        rescue StandardError => e
          puts "Error during processing: #{$!}"
          puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
        clar_notif = proc do |question|
          # return unless resource(:feature_flags, :clarifications)
          send_message(clarif_to_message(question), master_channel)
        rescue StandardError => e
          puts "Error during processing: #{$!}"
          puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
        contests.each do |contest|
          Thread.new do
            loop do
              contest.observe(score_notif, clar_notif)
            rescue StandardError => e
              puts e.message
              sleep(30)
            end
          end
        end
      end
    end
    # :nocov:
  end
end
