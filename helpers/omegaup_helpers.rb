# frozen_string_literal: true

module OmegaupHelpers
  def add_user_to_contest(user)
    contest = current_contest
    OMEGAUPCLI.add_user_to_contest(user, contest)
  end

  def current_contest
    contest = metadata[:current_contest]
    abort('Debes elegir un concurso para ser administrado antes /administrar_concurso') if contest.nil?

    OMEGAUPCLI.contest(contest)
  end

  def running_contest?
    contest_data = metadata[:observe_contest]
    (contest_data[:start_time]..contest_data[:finish_time]).include?(Time.now.to_i)
  end

  def clarif_to_message(question, answered = false)
    msg = "Open Clarification :: #{question[:contest_alias]} >> \n " \
          "#{question[:problem_alias]}\n" \
          "#{question[:message]}\n" \
          "reply_id: #{question[:clarification_id]}"
    msg += "\nAnswer: #{question[:answer]}" if answered
    msg
  end

  def respond_clarif(message, response)
    message_id = message.match(/reply_id: \d*/).to_s.gsub('reply_id: ', '')
    return if message_id.empty?

    OMEGAUPCLI.respond_clarif(message_id, response)

    send_message("Respondiendo a #{message_id}:\n#{response}")
  end

  def check_observing_contest!
    reason = if metadata[:current_contest] != args[:contest]
               'Contest changed, stopping notifications'
             elsif !running_contest?
               'Contest not running, stopping notifications'
             elsif metadata[:idempotency_token] != args[:idempotency_token]
               "Idempotency token changed: #{metadata[:idempotency_token]} != #{args[:idempotency_token]}"
             end

    return unless reason

    log_info(reason, channel: current_channel)
    abort
  end

  def minified_scoreboard(contest)
    result = {}
    scoreboard = contest.scoreboard
    scoreboard.users.each do |user|
      result[user.username] = user.problems.to_h { |p| [p[:alias], p[:points]] }
    end
    result
  end
end
