# frozen_string_literal: true

module UserCommands
  DEFAUL_LANG = 'es'
  FAIR_USE = <<~FAIRUSE.strip
    AVISO DE PRIVACIDAD
    Nuestro objetivo es servir como una plataforma de aprendizaje de programación y matemáticas. Los datos
    recolectados serán utilizados con fines estadísticos para mejorar los contenidos de la plataforma. No
    recolectaremos nombres para mantener la privacidad de los usuarios.
    Los estadísticos generados en la plataforma podrán ser publicados con fines científicos:
    * Dificultades de los estudiantes comunes.
    * Estadisticas por edades, países, ciudades, etc.
    * Estadísticas de progreso de los estudiantes.
    * Diseño de metodologías de aprendizaje.
    * Documentación de procesos de enseñanza.
  FAIRUSE

  def self.register_commands(bot)
    bot.register_command('/iniciar') do
      if bot_started?
        send_message('Ya has iniciado el bot. /help te mostrará la ayuda.')
      else
        User.transaction do
          user = User.create!(created_at: Time.now, updated_at: Time.now)
          user.channels.create!(adapter: provider_name, channel_id: current_channel)
        end
        send_message(FAIR_USE)
        redirect('/mis_datos')
      end
    end

    bot.register_command('/mis_datos') do
      user = current_user!
      send_message(<<~MYDATA
        Mi código de usuario: #{user.id}
        Fecha de nacimiento: #{user.date_of_birth || 'Sin datos'}. /agregar_fecha_de_nacimiento
        Usuario de omegaup: #{user.omegaup_username || 'Sin datos'}. /agregar_usuario_omegaup
        País: #{user.country || 'Sin datos'}. /agregar_pais
        Estado o Provincia: #{user.state || 'Sin datos'}. /agregar_estado
        Escuela: #{user.school || 'Sin datos'}. /agregar_escuela
        Quiero aprender Karel: #{user.karel_coder ? 'Sí. /ya_no_quiero_aprender_karel' : 'No /quiero_aprender_karel'}
        Quiero aprender C++: #{user.cpp_coder ? 'Sí. /ya_no_quiero_aprender_cpp' : 'No. /quiero_aprender_cpp'}
        Estoy suscrito a los anuncios: #{user.allow_newsletter ? 'Sí. /ya_no_quiero_recibir_anuncios' : 'No. /quiero_recibir_anuncios'}
        Mis Concursos: /mis_concursos
      MYDATA
                  )
    end

    bot.register_command('/agregar_escuela', school: '¿Cuál es tu escuela?') do
      user = current_user!
      user.school = params[:school]
      user.save
      send_message('Tu escuela ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_usuario_omegaup', omegaup_username: '¿Cuál es tu usuario de omegaup?') do
      user = current_user!
      user.omegaup_username = params[:omegaup_username]
      user.save
      send_message('Tu usuario ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_pais', country: '¿Cuál es tu país?') do
      user = current_user!
      user.country = params[:country]
      user.save
      send_message('Tu país ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_estado', state: '¿Cuál es tu estado/provincia?') do
      user = current_user!
      user.state = params[:state]
      user.save
      send_message('Tu estado/provincia ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_fecha_de_nacimiento', year: '¿En qué año naciste?', month: '¿En que mes naciste? (en número)', day: '¿Qué día del mes naciste?') do
      date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
      user = current_user!
      user.date_of_birth = date
      user.save
      send_message('Tu fecha de nacimiento ha sido guardada')
      redirect('/mis_datos')
    rescue Date::Error
      send_message('La fecha que ingresaste es incorrecta. Vuelve a intentarlo. /agregar_fecha_de_nacimiento')
    end

    bot.register_command('/quiero_aprender_karel') do
      user = current_user!
      user.karel_coder = true
      user.save
      send_message('Has sido registrado como alumno de karel')
      redirect('/mis_datos')
    end

    bot.register_command('/quiero_aprender_cpp') do
      user = current_user!
      user.cpp_coder = true
      user.save
      send_message('Has sido registrado como alumno de C++')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_aprender_karel') do
      user = current_user!
      user.karel_coder = false
      user.save
      send_message('Has sido dado de baja como alumno de karel')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_aprender_cpp') do
      user = current_user!
      user.cpp_coder = false
      user.save
      send_message('Has sido dado de baja como alumno de C++')
      redirect('/mis_datos')
    end
    
    bot.register_command('/quiero_recibir_anuncios') do
      user = current_user!
      user.allow_newsletter = true
      user.save
      send_message('Recibirás los anuncios de la comunidad. Descuida, prometemos no hacer mucho ruido.')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_recibir_anuncios') do
      user = current_user!
      user.allow_newsletter = false
      user.save
      send_message('Es triste verte partir. Pero siempre puedes volver. ')
      redirect('/mis_datos')
    end

    bot.register_command('/help') do
      send_message <<~HELP.squish.squeeze(' ').gsub('\\\\', "\n\n")
        Bienvenido al bot de aprendizaje de programación de Tacho. Puedes consultar más detalles en https://tacho.codes/bot
        Aquí podrás aprender un poco más de programación. Para iniciar el bot envía /iniciar.
        Para poder ver tus datos registrados puedes consultar con /mis_datos.
      HELP
      send_message(FAIR_USE)
    end
  end
end
