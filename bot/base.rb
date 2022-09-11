require 'kybus/bot'

module Charrobot
  class Base < Kybus::Bot::Base
    extend Kybus::DRY::ResourceInjector

    def omega
      @omega ||= Services.omega
    end

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

      send_message("Responiendo a #{message_id}:\n#{response}")
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
               .each { |clar| send_message(clarif_to_message(clar, true)) }
     end
    end

    def find_contest(name)
      omega.contest(name)
    end

    def observe_contest
      puts "Authorized Channel: #{master_channel}"
      score_notif = proc do |name, user, problem, points, last_score, contest_name|
        msg = "#{contest_name}::#{name} >>\n#{user} solved #{problem} with #{points} (+#{points - last_score})"
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
        contest.observe(score_notif, clar_notif)
      end
    end
  end
end
