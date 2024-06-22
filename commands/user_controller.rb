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
        metadata[:created_at] = Time.now
        metadata[:started] = true
        send_message(FAIR_USE)
        redirect('/mis_datos')
      end
    end

    bot.register_command('/mis_datos') do
      send_message(<<~MYDATA
        Fecha de nacimiento: #{metadata[:date_of_birth] || 'Sin datos'}. /agregar_fecha_de_nacimiento
        Usuario de omegaup: #{metadata[:omegaup_username] || 'Sin datos'}. /agregar_usuario_omegaup
        País: #{metadata[:country] || 'Sin datos'}. /agregar_pais
        Estado o Provincia: #{metadata[:state] || 'Sin datos'}. /agregar_estado
        Escuela: #{metadata[:school] || 'Sin datos'}. /agregar_escuela
        Quiero aprender Karel: #{metadata[:karel_coder] ? 'Sí. /ya_no_quiero_aprender_karel' : 'No /quiero_aprender_karel'}
        Quiero aprender C++: #{metadata[:cpp_coder] ? 'Sí. /ya_no_quiero_aprender_cpp' : 'No. /quiero_aprender_cpp'}
        Estoy suscrito a los anuncios: #{metadata[:allow_newsletter] ? 'Sí. /ya_no_quiero_recibir_anuncios' : 'No. /quiero_recibir_anuncios' }
        Me gustaría apoyar a la comunidad clasificando problemas: #{ metadata[:problem_tagger] ? 'Sí. /ya_no_quiero_clasificar_problemas' : 'No. /quiero_clasificar_problemas' }
      MYDATA
      )
    end

    bot.register_command('/agregar_escuela', school: '¿Cuál es tu escuela?') do
      metadata[:school] = params[:school]
      send_message('Tu escuela ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_usuario_omegaup', omegaup_username: '¿Cuál es tu usuario de omegaup?') do
      metadata[:omegaup_username] = params[:omegaup_username]
      send_message('Tu usuario ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_pais', country: '¿Cuál es tu país?') do
      metadata[:country] = params[:country]
      send_message('Tu país ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_estado', state: '¿Cuál es tu estado/provincia?') do
      metadata[:state] = params[:state]
      send_message('Tu estado/provincia ha sido guardado')
      redirect('/mis_datos')
    end

    bot.register_command('/agregar_fecha_de_nacimiento', year: '¿En qué año naciste?',
                                                         month: '¿En que mes naciste? (en número)', day: '¿Qué día del mes naciste?') do
      date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
      metadata[:date_of_birth] = date
      send_message('Tu fecha de nacimiento ha sido guardada')
      redirect('/mis_datos')
    rescue Date::Error
      send_message('La fecha que ingresaste es incorrecta. Vuelve a intentarlo. /agregar_fecha_de_nacimiento')
    end

    bot.register_command('/quiero_aprender_karel') do
      metadata[:karel_coder] = true
      send_message('Has sido registrado como alumno de karel')
      redirect('/mis_datos')
    end

    bot.register_command('/quiero_aprender_cpp') do
      metadata[:cpp_coder] = true
      send_message('Has sido registrado como alumno de C++')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_aprender_karel') do
      metadata[:karel_coder] = false
      send_message('Has sido dado de baja como alumno de karel')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_aprender_cpp') do
      metadata[:cpp_coder] = false
      send_message('Has sido dado de baja como alumno de C++')
      redirect('/mis_datos')
    end

    bot.register_command('/quiero_recibir_anuncios') do
      metadata[:allow_newsletter] = true
      send_message('Recibirás los anuncios de la comunidad. Descuida, prometemos no hacer mucho ruido.')
      redirect('/mis_datos')
    end

    bot.register_command('/ya_no_quiero_recibir_anuncios') do
      metadata[:allow_newsletter] = false
      send_message('Es triste verte partir. Pero siempre puedes volver. ')
      redirect('/mis_datos')
    end

    bot.register_command('/quiero_clasificar_problemas') do
      metadata[:problem_tagger] = true
      send_message('De vez en cuando te vamos a mandar algunos mensajes para pedir tu ayuda. Sólo te preguntaremos sobre problemas que hayas resuelto anteriormente. Gracias por ayudar a la comunidad.')
      redirect('/mis_datos')
    end
    
    bot.register_command('/ya_no_quiero_clasificar_problemas') do
      metadata[:problem_tagger] = false
      send_message('Ya no te pediremos ayuda con problemas. Cuando quieras puedes volver a ayudarnos.')
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
