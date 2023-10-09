module ContestsCommands
  def self.register_commands(bot)
    bot.register_command('/mis_concursos') do
      user = current_user!
      contests = user.active_contests.map(&:to_message_format)

      if contests.empty?
        send_message <<~NOCONTEST
          No estás registrado a ningún concurso.
          Puedes encontrar concursos en /proximos_concursos.
          También puedes activar los anuncios para recibir alertas cuando haya proximos concursos.
          /quiero_recibir_anuncios
        NOCONTEST
      else
        send_message(contests.join("\n---\n"))
      end
    end

    bot.register_command('/proximos_concursos') do
      user = current_user!
      contests = Contest.where('end_time >= ?', Time.now).map(&:to_message_format)
      if contests.empty?
        send_message <<~NOCONTEST
          No hay concursos próximos.
          #{user.allow_newsletter ? 'Activa las notificaciones para mantenerte al pendiente /quiero_recibir_anuncios' : ''}
          #{user.admin ? '/agregar_concurso' : ''}
        NOCONTEST
      else
        send_message(contests.join("\n---\n"))
      end
    end

    bot.register_command('/ver_concurso', contest: '¿Qué condigo de concurso quieres usar?') do
      contest = Contest.find_by(id: params[:contest])
      if contest.nil?
        send_message 'El concurso no existe'
      else
        send_message contest.to_message_format
      end
    end

    bot.register_command('/quiero_participar', contest: '¿Qué código de concurso quieres usar?') do
      user = current_user!
      contest = Contest.find_by(id: params[:contest])
      if contest.nil?
        send_message 'El concurso no existe'
      elsif user.contests.include?(contest)
        send_message 'El usuario ya está registrado en este concurso.'
      elsif user.omegaup_username.blank?
        send_message 'Debes agregar tu usuarios de omegaup primer. /agregar_usuario_omegaup'
      else
        User.transaction do
          omega.add_user_to_contest(user.omegaup_username, contest.short_name)

          user.contests << contest
        end
        send_message 'El usuario ha sido registrado en el concurso.'
      end
    end

    bot.register_command('/agregar_concurso',
                         name: '¿Nombre del concurso?',
                         short_name: '¿Nombre corto (identificador) del concurso?',
                         type: 'Elige el tipo de examen /karel /cpp',
                         topic: '¿Cuál es el tópico del examen?',
                         init_date: '¿Cuándo inicia el concurso?',
                         end_date: '¿Cuándo termina el concruso?',
                         description: '¿Cuál es la descripción del concurso?') do
      ensure_admin do
        Contest.transaction do
          contest = Contest.create!(
            short_name: params[:short_name],
            name: params[:name],
            karel: params[:type] == '/karel',
            cpp: params[:type] != '/karel',
            topic: params[:topic],
            description: params[:description],
            start_time: params[:init_date],
            end_time: params[:end_date]
          )
          omega.create_contest(
            short_name: contest.short_name,
            name: contest.short_name,
            languages: contest.karel ? Omega::KAREL_LANGS : Omega::OMI_LANGS,
            start_time: contest.start_time,
            finish_time: contest.end_time,
            description: contest.description
          )
          send_message("Concurso creado. /ver_concurso#{contest.id}")
        end
      end
    end
  end
end
