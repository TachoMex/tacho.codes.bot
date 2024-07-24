# frozen_string_literal: true

module OmegaupController
  def self.register_commands(bot)
    bot.register_command('/administrar_concurso', contest: '¿Cuál es el nombre corto del concurso?') do
      contest_name = params[:contest]
      group = metadata[:admin_group]

      abort('Necesitas dar de alta el grupo de admins primero /registrar_grupo_admins') if group.nil?

      contest = OMEGAUPCLI.contest(contest_name)

      abort("El grupo #{group} no pertenece a los administradores del concurso") unless contest.group_admin?(group)
      metadata[:current_contest] = contest_name
      metadata[:observe_contest] = {
        start_time: contest.data[:start_time],
        finish_time: contest.data[:finish_time]
      }

      send_message("Se va a administrar el concurso #{metadata[:current_contest]}")
    end

    bot.register_command('/agregar_usuario', user: '¿Cuál es el id de usuario?') do
      add_user_to_contest(params[:user])
      send_message("Se registró el usuario #{params[:user]} en #{metadata[:current_contest]}")
    end

    bot.register_command('/añadir_problema', problem: '¿Cuál problema deseas añadir?') do
      contest = current_contest
      contest.add_problem(params[:problem])
      send_message("Se registró el problema #{params[:problem]} en #{metadata[:current_contest]}")
    end

    bot.register_command('/activar_notificaciones') do
      contest = current_contest
      send_message('Se han activado las notificaciones')
      idempotency_token = Time.now.to_i
      metadata[:idempotency_token] = idempotency_token
      metadata[:scoreboard] = minified_scoreboard(contest)
      state.save!
      fork('contest_observer_clarif', contest: metadata[:current_contest], idempotency_token:)
      fork('contest_observer_score', contest: metadata[:current_contest], idempotency_token:)
    end

    bot.register_job('contest_observer_score', %i[contest idempotency_token]) do
      contest = current_contest
      check_observing_contest!
      time = metadata[:scoreboard_frequency] || 5

      last = metadata[:scoreboard]
      current = minified_scoreboard(contest)

      last.each do |username, previous_score|
        current_score = current[username.to_s]
        current_score.each do |problem, score|
          last_points = previous_score[problem.to_sym]
          current_points = score
          if current_points != last_points
            msg = "#{metadata[:current_contest]}>>\n#{username} solved #{problem} with #{current_points} (+#{current_points - last_points})"
            send_message(msg)
          end
        end
      end

      metadata[:scoreboard] = current
      fork_with_delay('contest_observer_score', time * 60, contest: metadata[:current_contest],
                                                           idempotency_token: args[:idempotency_token])
    end

    bot.register_job('contest_observer_clarif', %i[contest idempotency_token]) do
      contest = current_contest

      check_observing_contest!

      time = metadata[:clarif_frequency] || 5
      clarifications = contest.clarifications
      clarifications.select { |clar| clar[:answer].nil? || clar[:answer].empty? }
                    .each { |clar| send_message(clarif_to_message(clar)) }
      fork_with_delay('contest_observer_clarif', time * 60, contest: metadata[:current_contest],
                                                            idempotency_token: args[:idempotency_token])
    end

    bot.register_command('default') do
      respond_clarif(last_message.replied_message.raw_message, last_message.raw_message) if last_message.reply?
    end

    bot.register_command('/contest') do
      current_contest
      send_message(
        <<~CONTEST
          concurso activo: #{metadata[:current_contest]}
          frecuencia notificaciones:
          * clarificaciones: #{metadata[:clarif_frequency] || 5} /cambiar_frecuencia_clarificaciones
          * score: #{metadata[:score_frequency] || 5} /cambiar_frecuencia_scoreboard
          #{metadata[:mute_clarif] ? '/activar_notificaciones_clarificaciones' : '/desactivar_notificaciones_clarificaciones'}
          #{metadata[:mute_scoreboard] ? '/activar_notificaciones_scoreboard' : '/desactivar_notificaciones_scoreboard'}
          /desactivar_notificaciones
          /activar_notificaciones (reinicia el contador y dispara las notificaciones)
        CONTEST
      )
    end

    bot.register_command('/cambiar_frecuencia_clarificaciones',
                         frequency: '¿Cada cuántos minutos quieres actualizar?') do
      current_contest
      time = params[:frequency].to_i
      abort("Tiempo #{time} no valido") if time.zero? || time.negative?
      metadata[:clarif_frequency] = time
      time = [time, 15].min # Máximo es 15 por sqs.
      send_message("Se va a actualizar cada #{time} minutos.")
    end

    bot.register_command('/cambiar_frecuencia_scoreboard', frequency: '¿Cada cuántos minutos quieres actualizar?') do
      current_contest
      time = params[:frequency].to_i
      abort("Tiempo #{time} no valido") if time.zero? || time.negative?
      metadata[:clarif_scoreboard] = time
      time = [time, 15].min # Máximo es 15 por sqs.
      send_message("Se va a actualizar cada #{time} minutos.")
    end

    bot.register_command('/activar_notificaciones_clarificaciones') { metadata[:mute_clarif] = nil }
    bot.register_command('/desactivar_notificaciones_clarificaciones') { metadata[:mute_clarif] = true }
    bot.register_command('/activar_notificaciones_scoreboard') { metadata[:mute_scoreboard] = nil }
    bot.register_command('/desactivar_notificaciones_scoreboard') { metadata[:mute_scoreboard] = true }
    bot.register_command('/desactivar_notificaciones') { metadata[:idempotency_token] = nil }

    bot.rescue_from(Omega::OmegaError) do
      # :nocov:
      send_message(params[:_last_exception].message)
      # :nocov:
    end
  end
end
